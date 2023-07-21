provider "aws" {}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {
    type = list
}
variable "env_prefix" {}
variable "my_ip" {}
variable avail_zone {}
variable "instance_type" {}
variable "public_key_location" {}


resource "aws_vpc" "tf-rich-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "tf-rich-subnet-1" {
    vpc_id = aws_vpc.tf-rich-vpc.id
    cidr_block = var.subnet_cidr_block[0]
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

data "aws_vpc" "selected" {
    id = "vpc-01b21e69d4f15393b"
}

resource "aws_subnet" "tf-rich-subnet-2" {
    vpc_id = data.aws_vpc.selected.id
    cidr_block = var.subnet_cidr_block[1]
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-2"
    }
}

/*resource "aws_route_table" "myapp-route-table" {
    vpc_id = aws_vpc.tf-rich-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-gateway.id
    }
    tags = {
        Name = "${var.env_prefix}-rtb"
    }
}*/

resource "aws_default_route_table" "main-rtb" {
    default_route_table_id = aws_vpc.tf-rich-vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-gateway.id
    }
    tags = {
        Name = "${var.env_prefix}-drtb"
    }
}
resource "aws_internet_gateway" "myapp-gateway" {
    vpc_id = aws_vpc.tf-rich-vpc.id

    tags = {
        Name = "${var.env_prefix}-igw"
    }
}



resource "aws_default_security_group" "default-sg" {

    vpc_id = aws_vpc.tf-rich-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }

        ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"

        cidr_blocks = ["0.0.0.0/0"]
    }

        egress {
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
            prefix_list_ids = []

        }
        tags = {
            Name = "${var.env_prefix}-sg"
        }
}

data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  public_key = file(var.public_key_location)
}
resource "aws_instance" "myapp-instance" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.tf-rich-subnet-1.id
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    availability_zone = var.avail_zone
    associate_public_ip_address = true 
    key_name = aws_key_pair.ssh-key.key_name

    user_data = <<EOF
                    #!/bin/bash
                    sudo yum update -y && sudo yum install -y docker 
                    sudo systemctl start docker
                    sudo usermod -aG docker ec2_user
                    docker run -p 8080:80 nginx
                EOF

    tags = {
        Name = "${var.env_prefix}-server"
    }
}

output "aws_public_ip" {
    value = aws_instance.myapp-instance.public_ip
}
output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id
}

output "dev_vpc_id" {
    value = aws_vpc.tf-rich-vpc.id
}

output "aws_subnet" {
    value = aws_subnet.tf-rich-subnet-2.id
}