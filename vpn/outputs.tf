output "tailscale_router_public_ip" {
  description = "Public IP of the Tailscale subnet router (EIP)"
  value       = aws_eip.tailscale_router.public_ip
}

output "tailscale_router_private_ip" {
  description = "Private IP of the Tailscale subnet router"
  value       = aws_instance.tailscale_router.private_ip
}

output "worker_private_ips" {
  description = "Private IP of the K8s workers"
  value       = [for instance in aws_instance.k8s_workers : instance.private_ip]
}
