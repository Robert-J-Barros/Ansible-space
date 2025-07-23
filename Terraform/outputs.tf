output "instance_public_ips" {
  value = aws_instance.servers[*].public_ip
}

output "vpc_id" {
  value = aws_vpc.main.id
}
