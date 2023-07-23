provider "aws" {}

resource "aws_vpc" "tf-rich-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
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

module "myapp-subnet" {
    source = "./modules/subnets"
    subnet_cidr_block = var.subnet_cidr_block
    env_prefix = var.env_prefix
    avail_zone = var.avail_zone
    vpc_id = aws_vpc.tf-rich-vpc.id
    default_route_table_id = aws_vpc.tf-rich-vpc.default_route_table_id
}

module "myapp-server" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.tf-rich-vpc.id
    my_ip = var.my_ip
    env_prefix = var.env_prefix
    image_name = var.image_name
    public_key_location = var.public_key_location
    instance_type = var.instance_type
    subnet_id = module.myapp-subnet.subnet.id
    avail_zone = var.avail_zone
  
}
/*module "myapp-server" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.tf-rich-vpc.id
    my_ip = var.my_ip
    env_prefix = var.env_prefix
    image_name = var.image_name
    public_key_location = var.public_key_location
    instance_type = var.instance_type
    subnet_id = module.myapp-subnet.subnet.id
    avail_zone = var.avail_zone
}*/

