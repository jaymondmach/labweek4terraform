# Configure version of AWS provider plugin
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

# Define local variables
locals {
  project_name = "lab_week_4"
}

# Get the most recent AMI for Ubuntu 24.04 owned by Amazon
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# Create a VPC
resource "aws_vpc" "web" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${local.project_name}_vpc"
  }
}

# Create a public subnet
resource "aws_subnet" "web" {
  vpc_id                  = aws_vpc.web.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.project_name}_subnet"
  }
}

# Create an internet gateway for the VPC
resource "aws_internet_gateway" "web-gw" {
  vpc_id = aws_vpc.web.id

  tags = {
    Name = "${local.project_name}_it_gateway"
  }
}

# Create a route table for the VPC
resource "aws_route_table" "web" {
  vpc_id = aws_vpc.web.id

  tags = {
    Name = "${local.project_name}_route_table"
  }
}

# Add a default route to the route table
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.web.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.web-gw.id
}

# Associate the subnet with the route table
resource "aws_route_table_association" "web" {
  subnet_id      = aws_subnet.web.id
  route_table_id = aws_route_table.web.id
}

# Create a security group
resource "aws_security_group" "web" {
  name        = "allow_ssh"
  description = "allow ssh from home and work"
  vpc_id      = aws_vpc.web.id

  tags = {
    Name = "${local.project_name}_security_group"
  }
}

# Allow SSH access
resource "aws_vpc_security_group_ingress_rule" "web-ssh" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# Allow HTTP access
resource "aws_vpc_security_group_ingress_rule" "web-http" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# Allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "web-egress" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

# Create the EC2 instance
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  user_data              = file("${path.module}/scripts/cloud-config.yaml")
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              = aws_subnet.web.id

  tags = {
    Name = "${local.project_name}_instance"
  }
}

# Output the public IP and DNS of the EC2 instance
output "instance_ip_addr" {
  description = "The public IP and DNS of the web EC2 instance."
  value = {
    "public_ip" = aws_instance.web.public_ip
    "dns_name"  = aws_instance.web.public_dns
  }
}