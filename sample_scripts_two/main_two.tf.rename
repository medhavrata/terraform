#############################################################
# Variables
#############################################################

variable "private_key_path" {}
variable "key_name" {}
variable "region" {
    default = "eu-west-2"
}

variable "network_address_space"{
    default = "10.1.0.0/16"
}

variable "subnet1_address_space"{
    default = "10.1.0.0/24"
}

#############################################################
# Providers
#############################################################

provider "aws" {
    region = var.region
}

#############################################################
# Data
#############################################################

data "aws_availability_zones" "available" {}

data "aws_ami" "aws-linux"{
    most_recent = true
    owners      = ["amazon"]

    filter {
        name = "name"
        values = ["amzn-ami-hvm*"]
    }

    filter {
        name = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

#############################################################
# Resources
#############################################################

# NETWORKING #
resource "aws_vpc" "vpc" {
    cidr_block = var.network_address_space
    enable_dns_hostnames = "true"
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "subnet1" {
    cidr_block = var.subnet1_address_space
    vpc_id = aws_vpc.vpc.id
    map_public_ip_on_launch = "true"
    availability_zone = data.aws_availability_zones.available.names[0]
}

#ROUTING#

resource "aws_route_table" "rtb" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "rta_subnet1" {
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.rtb.id
}

# SECURITY GROUPS #
# Nginx security group#
resource "aws_security_group" "nginx-sg"{
    name = "nginx_sg"
    vpc_id = aws_vpc.vpc.id

    ingress = [ {
      description = "SSH"
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 22
      protocol = "tcp"
      to_port = 22
      ipv6_cidr_blocks = ["::/0"]
      self = null
      prefix_list_ids = null
      security_groups = null
    },
    {
      description = "HTTP"
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 80
      protocol = "tcp"
      to_port = 80
      ipv6_cidr_blocks = ["::/0"]
      self = null
      prefix_list_ids = null
      security_groups = null
    } ]
  
    egress = [ {
      description = "define egress rule"
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 0
      protocol = -1
      to_port = 0
      ipv6_cidr_blocks = null
      prefix_list_ids = null
      security_groups = null
      self = null
    } ]
}

# INSTANCES #
resource "aws_instance" "nginx1"{
    ami = data.aws_ami.aws-linux.id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.subnet1.id
    vpc_security_group_ids = [aws_security_group.nginx-sg.id]
    key_name = var.key_name

    connection {
        type = "ssh"
        host = self.public_ip
        user = "ec2-user"
        private_key = file(var.private_key_path)
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum install nginx -y",
            "sudo service nginx start",
            "sudo rm /usr/share/nginx/html/index.html",
            "echo '<html><head><title>Blue Team Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">Blue Team</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html"
        ]
    }
}

#############################################################
# Output
#############################################################

output "aws_instance_public_dns" {
    value = aws_instance.nginx1.public_dns
}