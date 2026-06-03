output "instance_public_ip" {
  value = aws_instance.name.public_ip
}

output "instance_pivate_ip" {
  value = aws_instance.name.private_ip
}

output "subnet_id" {
  value = aws_instance.name.subnet_id
}