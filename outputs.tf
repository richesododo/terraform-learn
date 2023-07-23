output "aws_public_ip" {
    value = module.myapp-server.server.public_ip
}

output "dev_vpc_id" {
    value = aws_vpc.tf-rich-vpc.id
}

output "aws_subnet_id" {
    value = aws_subnet.tf-rich-subnet-2.id
}