output "tailscale_router_public_ip" {
  description = "Public IP of the Tailscale subnet router (EIP)"
  value       = aws_eip.tailscale_router.public_ip
}

output "tailscale_router_private_ip" {
  description = "Private IP of the Tailscale subnet router"
  value       = aws_instance.tailscale_router.private_ip
}

output "test_instance_private_ip" {
  description = "Private IP of the VPN test instance"
  value       = aws_instance.vpn_test.private_ip
}
