variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {
    type = list
}
variable "env_prefix" {}
variable "my_ip" {}
variable avail_zone {}
variable "instance_type" {}
variable "public_key_location" {}
variable "private_key_location" {}
variable "image_name" {}