### creation of VPC ###
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  instance_tenancy = "default"

  tags = {
    Name = "${var.project}-vpc"
    Project = var.project
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Declaration the data source for availalbility zone
data "aws_availability_zones" "az" {
  state = "available"
}

### Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-igw"
    Project = var.project
  }
}

### Subnet creation - public1
resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr,3,0)
  availability_zone = data.aws_availability_zones.az.names[0]
  map_public_ip_on_launch = true


   tags = {
    Name = "${var.project}-public1"
    Project = var.project
  }
}


### Subnet creation - public2
resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr,3,1)
  availability_zone = data.aws_availability_zones.az.names[1]
  map_public_ip_on_launch = true
  

   tags = {
    Name = "${var.project}-public2"
    Project = var.project
  }
}


### Subnet creation - public3
resource "aws_subnet" "public3" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr,3,2)
  availability_zone = data.aws_availability_zones.az.names[2]
  map_public_ip_on_launch = true
  

   tags = {
    Name = "${var.project}-public3"
    Project = var.project
  }
}

### Subnet creation - private1
resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr,3,3)
  availability_zone = data.aws_availability_zones.az.names[0]
  map_public_ip_on_launch = false
  

   tags = {
    Name = "${var.project}-private1"
    Project = var.project
  }
}

### Subnet creation - private2
resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr,3,4)
  availability_zone = data.aws_availability_zones.az.names[1]
  map_public_ip_on_launch = false
  

   tags = {
    Name = "${var.project}-private2"
    Project = var.project
  }
}

### Subnet creation - private3
resource "aws_subnet" "private3" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr,3,5)
  availability_zone = data.aws_availability_zones.az.names[2]
  map_public_ip_on_launch = false
  

   tags = {
    Name = "${var.project}-private3"
    Project = var.project
  }
}

## elastic IP allocation
resource "aws_eip" "eip" {
  vpc      = true
}

## creation of NAT-gw
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public2.id

   tags = {
    Name = "${var.project}-NATgw"
    Project = var.project
  }
}

## route table creation -public
resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
   tags = {
    Name = "${var.project}-public-rtb"
    Project = var.project
  }
}


## route table creation -private
resource "aws_route_table" "private-rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
   tags = {
    Name = "${var.project}-private-rtb"
    Project = var.project
  }
}

## route table association - public1
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public-rtb.id
}

## route table association - public2
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public-rtb.id
}

## route table association - public3
resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public-rtb.id
}

## route table association - private1
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private-rtb.id
}

## route table association - private2
resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private-rtb.id
}

## route table association - private3
resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private-rtb.id
}