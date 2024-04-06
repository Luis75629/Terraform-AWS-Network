output "vpc_id" {
  value = aws_vpc.AWS-terraform.id
}

output "instance_1_public_ip" {
  value = aws_instance.VM1.public_ip
}

output "instance_2_public_ip" {
  value = aws_instance.VM2.public_ip
}
