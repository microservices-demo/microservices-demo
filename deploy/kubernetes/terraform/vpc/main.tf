provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc_main_amatic" {
  cidr_block = var.vpc_cidr_block
  #enable_dns_hostnames = true

  tags =  {
    Name = "vpc_main_amatic"
  }
}
resource "aws_internet_gateway" "gateway_amatic" {
  vpc_id = aws_vpc.vpc_main_amatic.id
  tags =  {
    Name = "gateway_matic"
  }
}

// Public subnetwork it's route table and it's association
resource "aws_subnet" "public_subnetwork_amatic" {
  vpc_id = aws_vpc.vpc_main_amatic.id
  cidr_block = var.public_subnetwork_cidr_block
  tags = {
    Name = "public_subnetwork_amatic"
  }
  availability_zone = var.availability_zone

  map_public_ip_on_launch = true
}
resource "aws_route_table" "public_subnetwork_route_table_amatic" {
  vpc_id = aws_vpc.vpc_main_amatic.id

  route {
    cidr_block = var.route_table_cidr_block
    gateway_id = aws_internet_gateway.gateway_amatic.id
  }

  tags  = {
    Name = "public_subnetwork_route_table_amatic"
  }
}
resource "aws_route_table_association" "public_route_table_association_amatic" {
  subnet_id = aws_subnet.public_subnetwork_amatic.id
  route_table_id = aws_route_table.public_subnetwork_route_table_amatic.id
}


// Private subnetwork it's route table and it's association
resource "aws_subnet" "private_subnetwork_amatic" {
  vpc_id = aws_vpc.vpc_main_amatic.id
  cidr_block = var.private_subnetwork_cidr_block
  tags =  {
    Name = "private_subnetwork_amatic"
  }
  availability_zone = var.availability_zone

  map_public_ip_on_launch = true
}
resource "aws_route_table" "private_subnetwork_route_table_amatic" {
  vpc_id = aws_vpc.vpc_main_amatic.id

  route {
    cidr_block = var.route_table_cidr_block
    gateway_id = aws_internet_gateway.gateway_amatic.id
  }

  tags = {
    Name = "private_subnetwork_route_table_amatic"
  }
}
resource "aws_route_table_association" "private_route_table_association_amatic" {
  subnet_id = aws_subnet.private_subnetwork_amatic.id
  route_table_id = aws_route_table.private_subnetwork_route_table_amatic.id
}
