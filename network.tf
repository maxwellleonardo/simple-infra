resource "aws_vpc" "simple-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "simple-vpc"
  }
}

resource "aws_subnet" "simple-subnet-public-1" {
  vpc_id                  = aws_vpc.simple-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "simple-subnet-public-1"
  }
}

resource "aws_subnet" "simple-subnet-private-1" {
  vpc_id                  = aws_vpc.simple-vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "simple-subnet-private-1"
  }
}

resource "aws_subnet" "simple-subnet-private-2" {
  vpc_id                  = aws_vpc.simple-vpc.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1b"

  tags = {
    Name = "simple-subnet-private-2"
  }
}

resource "aws_internet_gateway" "simple-gw" {
  vpc_id = aws_vpc.simple-vpc.id

  tags = {
    Name = "simple-gw"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.simple-subnet-public-1.id
  depends_on    = [aws_internet_gateway.simple-gw]
}

resource "aws_route_table" "simple-rt-public" {
  vpc_id = aws_vpc.simple-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.simple-gw.id
  }

  tags = {
    Name = "simple-rt-public-1"
  }
}

resource "aws_route_table" "simple-rt-private" {
  vpc_id = aws_vpc.simple-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "simple-rt-private-1"
  }
}

resource "aws_route_table_association" "simple-public-1-a" {
  subnet_id      = aws_subnet.simple-subnet-public-1.id
  route_table_id = aws_route_table.simple-rt-public.id
}

resource "aws_route_table_association" "simple-private-1-a" {
  subnet_id      = aws_subnet.simple-subnet-private-1.id
  route_table_id = aws_route_table.simple-rt-private.id
}

resource "aws_route_table_association" "simple-private-2-a" {
  subnet_id      = aws_subnet.simple-subnet-private-2.id
  route_table_id = aws_route_table.simple-rt-private.id
}

