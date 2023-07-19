provider "aws" {}

variable "cidr_blocks" {
    description = "cidr_blocks and name tags for vpc and subnets"
    type = list(object({
        cidr_block = string
        name = string
    }))
}

variable avail_zone {}



variable "environment" {
    description = "deployment environment"
}
resource "aws_vpc" "tf-rich-vpc" {
    cidr_block = var.cidr_blocks[0].cidr_block
    tags = {
        Name: var.cidr_blocks[0].name
    }
}

resource "aws_subnet" "tf-rich-subnet-1" {
    vpc_id = aws_vpc.tf-rich-vpc.id
    cidr_block = var.cidr_blocks[1].cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: var.cidr_blocks[1].name
    }
}

data "aws_vpc" "selected" {
    id = "vpc-01b21e69d4f15393b"
}

resource "aws_subnet" "tf-rich-subnet-2" {
    vpc_id = data.aws_vpc.selected.id
    cidr_block = var.cidr_blocks[2].cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: var.cidr_blocks[2].name
    }
}

output "dev_vpc_id" {
    value = aws_vpc.tf-rich-vpc.id
}

output "aws_subnet" {
    value = aws_subnet.tf-rich-subnet-2.id
}