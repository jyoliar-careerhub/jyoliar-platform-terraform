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

resource "aws_security_group" "vpn_test" {
  vpc_id      = local.vpc_outputs["vpc_id"]
  name        = "${var.env}-vpn-test-sg"
  description = "Security group for VPN test instance"

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

locals {
  additional_key_user_data = var.additional_public_key != "" ? "#!/bin/bash\necho '${var.additional_public_key}' >> /home/ubuntu/.ssh/authorized_keys" : null
}

# Tailscale Subnet Router
resource "aws_instance" "tailscale_router" {
  ami           = "ami-027308df79a86d22c" # Ubuntu 24.04 ARM64 ap-south-1
  instance_type = "t4g.micro"
  subnet_id     = local.vpc_outputs["core_public_subnet_ids"][0]
  key_name      = aws_key_pair.vpn_server.key_name

  source_dest_check      = false
  vpc_security_group_ids = [aws_security_group.tailscale_router.id]

  user_data = <<-EOT
    #!/bin/bash
    set -e

    # Add additional SSH key
    %{if var.additional_public_key != ""}
    echo '${var.additional_public_key}' >> /home/ubuntu/.ssh/authorized_keys
    %{endif}

    # Enable IP forwarding
    cat <<EOF | tee /etc/sysctl.d/99-tailscale.conf
    net.ipv4.ip_forward = 1
    net.ipv6.conf.all.forwarding = 1
    EOF
    sysctl -p /etc/sysctl.d/99-tailscale.conf

    # Install Tailscale
    curl -fsSL https://tailscale.com/install.sh | sh

    # Start Tailscale as subnet router
    tailscale up --authkey=${var.tailscale_auth_key} --advertise-routes=${local.vpc_outputs["vpc_cidr_block"]} --accept-routes
  EOT

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.env}-tailscale-router"
  }
}

resource "aws_eip" "tailscale_router" {
  instance = aws_instance.tailscale_router.id

  tags = {
    Name = "${var.env}-tailscale-router-eip"
  }
}

# VPN Test Instance
resource "aws_instance" "vpn_test" {
  ami           = "ami-027308df79a86d22c" # Ubuntu 24.04 ARM64 ap-south-1
  instance_type = "t4g.micro"
  subnet_id     = local.vpc_outputs["core_private_subnet_ids"][0]
  key_name      = aws_key_pair.vpn_server.key_name

  vpc_security_group_ids = [aws_security_group.vpn_test.id]

  user_data = local.additional_key_user_data

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.env}-vpn-test"
  }
}
