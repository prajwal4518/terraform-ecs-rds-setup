# Random integer Generator
resource "random_integer" "priority" {
  min = 1
  max = 5
}

# VPC
resource "aws_vpc" "this" {
  cidr_block = local.vpc_cidr
  tags = {
    Name = "${var.app-name}-vpc"
  }
}

# Public subnets
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.this.id
  count             = length(var.availability_zones)
  cidr_block        = cidrsubnet(local.vpc_cidr, 8, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name = "${var.app-name}-public-${count.index + 1}"
  }
}

# Private subnets
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.this.id
  count             = length(var.availability_zones)
  cidr_block        = cidrsubnet(local.vpc_cidr, 8, count.index + 10)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name = "${var.app-name}-private-${count.index + 1}"
  }
}

# Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.app-name}-igw"
  }
}

# Elastic IP
resource "aws_eip" "eip" {
  count  = length(var.availability_zones)
  domain = "vpc"
}

# NAT gateways
resource "aws_nat_gateway" "nat" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public1[count.index].id
  tags = {
    Name = "${var.app-name}-nat-${count.index + 1}"
  }
}

# Public route tables
resource "aws_route_table" "public" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.app-name}-public-rt-${count.index + 1}"
  }
}

# Private route tables
resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "${var.app-name}-private-rt-${count.index + 1}"
  }
}

# Public route table associations
resource "aws_route_table_association" "public1" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public1[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

# Private route table associations
resource "aws_route_table_association" "private1" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private1[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
