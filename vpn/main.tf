# NAT Instance
module "nat" {
  source = "../_modules/nat"

  name             = "${var.env}-vpn-nat"
  public_subnet_id = local.vpc_outputs["core_public_subnet_ids"][0]
  route_table_id   = local.vpc_outputs["private_route_table_id"]
}

# Security Groups
resource "aws_security_group" "tailscale_router" {
  vpc_id      = local.vpc_outputs["vpc_id"]
  name        = "${var.env}-tailscale-router-sg"
  description = "Security group for Tailscale subnet router"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.vpc_outputs["vpc_cidr_block"]]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "k8s_workers" {
  vpc_id      = local.vpc_outputs["vpc_id"]
  name        = "${var.env}-k8s-workers-sg"
  description = "Security group for K8s workers"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.vpc_outputs["vpc_cidr_block"]]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Key Pair
resource "aws_key_pair" "vpn_server" {
  key_name   = "vpn-server"
  public_key = var.ssh_public_key
}

data "aws_ami" "ubuntu_arm64" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

locals {
  tailscale_router_user_data = <<-EOF
  #!/bin/bash
  set -e

  # Additional SSH key
  %{if var.additional_public_key != ""}
  echo '${var.additional_public_key}' >> /home/ubuntu/.ssh/authorized_keys
  %{endif}

  # sysctl: reverse path filter loose mode for Tailscale
  cat > /etc/sysctl.d/99-tailscale.conf <<'SYSCTL'
  net.ipv4.ip_forward = 1
  net.ipv6.conf.all.forwarding = 1
  net.ipv4.conf.all.rp_filter = 2
  net.ipv4.conf.default.rp_filter = 2
  SYSCTL
  sysctl --system

  # Install Tailscale
  curl -fsSL https://tailscale.com/install.sh | sh
  systemctl enable --now tailscaled

  # Authenticate and configure as subnet router
  tailscale up --authkey=${var.tailscale_auth_key}

  # Protective ip rule: prevent accept-routes from overriding local subnet routing
  ip rule add to ${local.vpc_outputs["vpc_cidr_block"]} lookup main priority 5269 2>/dev/null || true

  # Persist protective ip rule across reboots
  mkdir -p /etc/networkd-dispatcher/routable.d
  cat > /etc/networkd-dispatcher/routable.d/49-protect-local-route.sh <<'PROTECT'
  #!/bin/bash
  ip rule add to ${local.vpc_outputs["vpc_cidr_block"]} lookup main priority 5269 2>/dev/null || true
  PROTECT
  chmod 755 /etc/networkd-dispatcher/routable.d/49-protect-local-route.sh

  tailscale set \
    --advertise-routes=${local.vpc_outputs["vpc_cidr_block"]} \
    --accept-routes \
    --snat-subnet-routes=true \
    --hostname=${var.env}-tailscale-router
  EOF

  additional_key_user_data = var.additional_public_key != "" ? "#!/bin/bash\necho '${var.additional_public_key}' >> /home/ubuntu/.ssh/authorized_keys" : null
}

# Tailscale Subnet Router

# Homelab → AWS Worker 통신을 위한 VPC Route
# kubelet → API Server, Pod-to-Pod VXLAN 등 워커가 homelab에 먼저 접근하는 트래픽용
resource "aws_route" "homelab_via_tailscale" {
  for_each               = toset(var.other_site_cidr_blocks)
  route_table_id         = local.vpc_outputs["private_route_table_id"]
  destination_cidr_block = each.value
  network_interface_id   = aws_instance.tailscale_router.primary_network_interface_id
}

resource "aws_eip" "tailscale_router" {
  instance = aws_instance.tailscale_router.id

  tags = {
    Name = "${var.env}-tailscale-router-eip"
  }
}

# VPN Test Instance
data "aws_subnet" "core_public_01" {
  id = local.vpc_outputs["core_public_subnet_ids"][0]
}

data "aws_subnet" "core_private_01" {
  id = local.vpc_outputs["core_private_subnet_ids"][0]
}

locals {
  k8s_workers = {
    "k8s-node-01" = {
      subnet_id     = local.vpc_outputs["core_private_subnet_ids"][0]
      private_ip    = cidrhost(data.aws_subnet.core_private_01.cidr_block, 100)
      instance_type = "t4g.micro"
      ami           = data.aws_ami.ubuntu_arm64.id
    }
  }
}
resource "aws_instance" "tailscale_router" {
  ami           = data.aws_ami.ubuntu_arm64.id
  instance_type = "t4g.micro"
  subnet_id     = local.vpc_outputs["core_public_subnet_ids"][0]
  private_ip    = cidrhost(data.aws_subnet.core_public_01.cidr_block, 100)
  key_name      = aws_key_pair.vpn_server.key_name

  source_dest_check      = false
  vpc_security_group_ids = [aws_security_group.tailscale_router.id]

  user_data = local.tailscale_router_user_data

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.env}-tailscale-router"
  }
}


resource "aws_instance" "k8s_workers" {
  for_each      = local.k8s_workers
  ami           = each.value.ami
  instance_type = each.value.instance_type
  subnet_id     = each.value.subnet_id
  private_ip    = each.value.private_ip


  key_name               = aws_key_pair.vpn_server.key_name
  vpc_security_group_ids = [aws_security_group.k8s_workers.id]

  user_data = local.additional_key_user_data

  root_block_device {
    volume_size = 60
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.env}-${each.key}"
  }
}
