terraform {
  required_version = ">= 1.0"
}

resource "aws_vpc" "lab_1" {
  cidr_block = var.vpc_cidr
  tags       = merge(var.tags, { Name = "main-vpc" })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.lab_1.id
  cidr_block              = var.public_subnet
  map_public_ip_on_launch = true
  availability_zone       = var.az
  tags                    = merge(var.tags, { Name = "public-subnet" })
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.lab_1.id
  cidr_block              = var.public_subnet_b
  map_public_ip_on_launch = true
  availability_zone       = var.az_2
  tags                    = merge(var.tags, { Name = "public-subnet-b" })
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.lab_1.id
  cidr_block        = var.private_subnet
  availability_zone = var.az
  tags              = merge(var.tags, { Name = "private-subnet" })
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.lab_1.id
  cidr_block        = var.private_subnet_b
  availability_zone = var.az_2
  tags              = merge(var.tags, { Name = "private-subnet-b" })
}

resource "aws_internet_gateway" "lab_1" {
  vpc_id = aws_vpc.lab_1.id
  tags   = merge(var.tags, { Name = "main-igw" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab_1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_1.id
  }
  tags = merge(var.tags, { Name = "public-rt" })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "lab_1" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags          = merge(var.tags, { Name = "main-nat" })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.lab_1.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.lab_1.id
  }
  tags = merge(var.tags, { Name = "private-rt" })
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}


