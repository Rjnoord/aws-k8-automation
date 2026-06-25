output "instance_public_ip" {
  description = "public_IP_EC2"
  value       = aws_instance.web.public_ip
}

output "instance_id" {
  description = "EC2_Instance_ID"
  value       = aws_instance.web.id
}

