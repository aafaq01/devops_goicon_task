provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "web_app_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "WebAppVPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.web_app_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.web_app_vpc.id
  tags = {
    Name = "WebAppIGW"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.web_app_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "web_app_sg" {
  name        = "web-app-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.web_app_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebAppSecurityGroup"
  }
}

resource "aws_instance" "web_app_instance" {
  ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.web_app_sg.name]

  tags = {
    Name = "WebAppInstance"
  }
}

output "public_ip" {
  value = aws_instance.web_app_instance.public_ip
}