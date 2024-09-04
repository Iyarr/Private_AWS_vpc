output "ec2_global_ips" {
  value = aws_instance.server.public_ip
}