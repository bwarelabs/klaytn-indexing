resource "aws_vpc" "graph-indexer-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "graph-indexer-vpc"
  }
}

data "aws_availability_zones" "available" {}

# Subnets for EKS availability zones
resource "aws_subnet" "graph-indexer-eks-subnets" {
  count = var.vpc_availablitiy_zones

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.graph-indexer-vpc.id

  tags = {
    Name = "graph-indexer-eks-subnets"
  }
}

# Subnets for IGW availability zones
resource "aws_subnet" "graph-indexer-igw-subnets" {
  count = var.vpc_availablitiy_zones

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.20${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.graph-indexer-vpc.id

  tags = {
    Name = "graph-indexer-igw-subnets",
  }
}

# Subnets for RDS availability zones
resource "aws_subnet" "graph-indexer-rds-subnets" {
  count = var.vpc_availablitiy_zones

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.10${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.graph-indexer-vpc.id

  tags = {
    Name = "graph-indexer-rds-subnets"
  }
}

resource "aws_db_subnet_group" "graph-indexer-rds-subnet-group" {
  name       = "graph-indexer-rds-subnet-group"
  subnet_ids = aws_subnet.graph-indexer-rds-subnets[*].id
}

# IGW for the VPC
resource "aws_internet_gateway" "graph-indexer-igw" {
  vpc_id = aws_vpc.graph-indexer-vpc.id

  tags = {
    Name = "graph-indexer-igw"
  }
}

# IPs to be attached to NAT Gateways
resource "aws_eip" "graph-indexer-eks-nat-eip" {
  count = var.vpc_availablitiy_zones
  vpc = true
  depends_on = [aws_internet_gateway.graph-indexer-igw]

  tags = {
    Name = "graph-indexer-nat-eip"
  }
}

# NAT Gateways
resource "aws_nat_gateway" "graph-indexer-eks-nat-gateway" {
  count = var.vpc_availablitiy_zones
  allocation_id = aws_eip.graph-indexer-eks-nat-eip.*.id[count.index]
  subnet_id = aws_subnet.graph-indexer-igw-subnets.*.id[count.index]

  tags = {
    Name = "graph-indexer-nat-gateway"
  }
  depends_on = [aws_internet_gateway.graph-indexer-igw]
}

# Routing table for IGW
resource "aws_route_table" "graph-indexer-routing-table" {
  vpc_id = aws_vpc.graph-indexer-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.graph-indexer-igw.id
  }
}

# Routing tables for NAT Gateways
resource "aws_route_table" "graph-indexer-routing-table-nat" {
  count = var.vpc_availablitiy_zones
  vpc_id = aws_vpc.graph-indexer-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.graph-indexer-eks-nat-gateway.*.id[count.index]
  }
}

# Associate routing tables to eks subnets
resource "aws_route_table_association" "graph-indexer-eks-routing-table-association" {
  count = var.vpc_availablitiy_zones

  subnet_id      = aws_subnet.graph-indexer-eks-subnets.*.id[count.index]
  route_table_id = aws_route_table.graph-indexer-routing-table-nat.*.id[count.index]
}

# Associate routing tables to rds subnets
resource "aws_route_table_association" "graph-indexer-rds-routing-table-association" {
  count = var.vpc_availablitiy_zones

  subnet_id      = aws_subnet.graph-indexer-rds-subnets.*.id[count.index]
  route_table_id = aws_route_table.graph-indexer-routing-table.id
}

# Associate routing tables to igw subnets
resource "aws_route_table_association" "graph-indexer-igw-routing-table-association" {
  count = var.vpc_availablitiy_zones

  subnet_id      = aws_subnet.graph-indexer-igw-subnets.*.id[count.index]
  route_table_id = aws_route_table.graph-indexer-routing-table.id
}