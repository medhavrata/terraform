provider "aws"{
    region = "eu-west-2"
}

resource "aws_instance" "example" {
    ami = "ami-074771aa49ab046e7"
    instance_type = "t2.micro"

    tags = {
      "Name" = "terraform-example"
    }
}