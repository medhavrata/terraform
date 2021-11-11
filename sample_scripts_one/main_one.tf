# This 

#############################################################
# Variables
#############################################################

variable "private_key_path" {}
variable "key_name" {}
variable "region" {
    default = "eu-west-2"
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

data "aws_ami" "aws_linux" {
    most_recent = true
    owners = ["amazon"]

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

#This will use the default VPC. It WILL NOT delete the default VPC on terraform destroy
resource "aws_default_vpc" "default" {
  
}

resource "aws_security_group" "allow_ssh" {
    name = "nginx_demo"
    description = "Allows ports for nginx demo"
    vpc_id = aws_default_vpc.default.id

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

resource "aws_instance" "nginx" {
  ami = data.aws_ami.aws_linux.id
  instance_type = "t2.micro"
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file(var.private_key_path)
  }
  provisioner "remote-exec" {
    inline = [
        "sudo yum install nginx -y",
        "sudo service nginx start"
    ]
  }
}

#############################################################
# Output
#############################################################

output "aws_instance_public_dns" {
  value = aws_instance.nginx.public_dns
}