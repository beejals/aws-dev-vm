# Create a VPC
resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.env}"
  }
}

# Create subnet for the VPC
resource "aws_subnet" "app_public_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.subnet_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone

  tags = {
    Name = "${var.env}-public"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "app_internet_gateway" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.env}-igw"
  }
}

# Create route table
resource "aws_route_table" "app_public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.env}-public-rt"
  }
}

# add default route to the route table
# here all addresses are routed via internet gateway
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.app_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.app_internet_gateway.id
}

# Associate our route table with the vpc subnet
resource "aws_route_table_association" "app_public_rt_assoc" {
  subnet_id      = aws_subnet.app_public_subnet.id
  route_table_id = aws_route_table.app_public_rt.id
}

# Create security group for the VPC
resource "aws_security_group" "app_sg" {
  name        = "${var.env}_sg"
  description = "${var.env} security group"
  vpc_id      = aws_vpc.app_vpc.id
}

# create ingress rule for SSH traffic
resource "aws_security_group_rule" "app_sg_rule_ingress_ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  # restrict access to request from specific IP
  cidr_blocks       = ["${chomp(data.http.my_ip.response_body)}/32"]
  security_group_id = aws_security_group.app_sg.id
}

# create ingress rule for HTTP traffic
resource "aws_security_group_rule" "app_sg_rule_ingress_http" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  # restrict access to request from specific IP for dev and staging only
  cidr_blocks       = var.env == "prod" ? ["0.0.0.0/0"] : ["${chomp(data.http.my_ip.response_body)}/32"]
  security_group_id = aws_security_group.app_sg.id
}

# create ingress rule for HTTPS traffic
resource "aws_security_group_rule" "app_sg_rule_ingress_https" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"
  # restrict access to request from specific IP for dev and staging only
  cidr_blocks       = var.env == "prod" ? ["0.0.0.0/0"] : ["${chomp(data.http.my_ip.response_body)}/32"]
  security_group_id = aws_security_group.app_sg.id
}

# create egress rule to allow access to all traffic towards internet
resource "aws_security_group_rule" "app_sg_rule_egress_to_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app_sg.id
}

# create aws key pair using public key in your .ssh directory
resource "aws_key_pair" "app_auth_key" {
  key_name   = "${var.env}-key"
  public_key = file("~/.ssh/${var.identityfile_name}.pub")
}

# Create VM instance
resource "aws_instance" "app_vm" {
  ami                    = data.aws_ami.server_ami.id
  instance_type          = var.ec2_instance_type
  key_name               = aws_key_pair.app_auth_key.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  subnet_id              = aws_subnet.app_public_subnet.id
  user_data              = templatefile("templates/userdata.tpl", {var1=var.github_token})

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "${var.env}-node"
  }

  # update ssh config file on you local machine
  provisioner "local-exec" {
    command = templatefile("templates/${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip
      user         = "ubuntu",
      identityfile = "~/.ssh/${var.identityfile_name}"
    })
    interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  }
}