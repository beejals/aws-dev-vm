# module input variables
variable "vpc_cidr_block" {}
variable "vpc_name" {}
variable "public_subnet_cidr_block" {}
variable "private_subnet_cidr_block" {}
variable "availability_zone" {}

# module output variables
output "app_vpc_id" {
  value = aws_vpc.app_vpc.id
}

output "app_vpc_public_subnets" {
  value = aws_subnet.app_public_subnet.*.id
}

output "app_vpc_public_subnets_cidr_block" {
  value = aws_subnet.app_public_subnet.*.cidr_block
}


# Create a VPC
resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}

# Create public subnet for the VPC
resource "aws_subnet" "app_public_subnet" {
  count                   = length(var.public_subnet_cidr_block)
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = element(var.public_subnet_cidr_block, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.availability_zone, count.index)

  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index}"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "app_internet_gateway" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Create public subnet route table
resource "aws_route_table" "app_public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# add default route to the route table
# here all addresses are routed via internet gateway
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.app_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.app_internet_gateway.id
}

# Associate public route table with the public subnets
resource "aws_route_table_association" "app_public_rt_assoc" {
  count          = length(aws_subnet.app_public_subnet)
  subnet_id      = aws_subnet.app_public_subnet[count.index].id
  route_table_id = aws_route_table.app_public_rt.id
}

# Create private subnet for the VPC
resource "aws_subnet" "app_private_subnet" {
  count             = length(var.private_subnet_cidr_block)
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = element(var.private_subnet_cidr_block, count.index)
  availability_zone = element(var.availability_zone, count.index)

  tags = {
    Name = "${var.vpc_name}-private-subnet-${count.index}"
  }
}

# Create private subnet route table
resource "aws_route_table" "app_private_rt" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

# Associate private route table with the private subnets
resource "aws_route_table_association" "app_private_rt_assoc" {
  count          = length(aws_subnet.app_private_subnet)
  subnet_id      = aws_subnet.app_private_subnet[count.index].id
  route_table_id = aws_route_table.app_private_rt.id
}
