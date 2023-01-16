# Configure the AWS Provider

provider "aws" {
  region  = "us-east-1"
  access_key = "add access key"
  secret_key = "add secret access key"
}

# 1. Create vpc

resource "aws_vpc" "main-project" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames    = "true"

  tags = {
    Name = "project1"
  }
}

# 2. Create Internet Gateway

resource "aws_internet_gateway" "project1-igw" {
  vpc_id = aws_vpc.main-project.id

  tags = {
    Name = "project1-igw"
  }
}

# 3. Create Custom Route Table

resource "aws_route_table" "main-project1-rt" {
  vpc_id = aws_vpc.main-project.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project1-igw.id
  }

  tags = {
    Name = "main-project1-rt"
  }
}

# 4. Create a Subnet

resource "aws_subnet" "project1-subnet" {
  vpc_id     = aws_vpc.main-project.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "prod-subnet"
  }
}

# 5. Associate subnet to route table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.project1-subnet.id
  route_table_id = aws_route_table.main-project1-rt.id
}

# 6. Create security group to allow port 22, 80, 443

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.main-project.id

  ingress {
    description      = "Https"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# 7. create ubuntu server and install/enable apache2

resource "aws_instance" "web-server" {
  ami           = "ami-06878d265978313ca"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.project1-subnet.id
  availability_zone = "us-east-1a"
  associate_public_ip_address = true
  key_name = "web-project"
  security_groups = [aws_security_group.allow_web.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              EOF

  tags = {
    Name = "web-server"
  }
}