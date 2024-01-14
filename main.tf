# Create a VPC
resource "aws_vpc" "dev_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

# Create subnet for the dev VPC
resource "aws_subnet" "dev_public_subnet" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ca-central-1a"

  tags = {
    Name = "dev-public"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "dev_internet_gateway" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

# Create route table
resource "aws_route_table" "dev_public_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "dev-public-rt"
  }
}

# add default route to the route table
# here all addresses are routed via internet gateway
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.dev_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev_internet_gateway.id
}

# Associate our route table with the dev subnet
resource "aws_route_table_association" "dev_public_assoc" {
  subnet_id      = aws_subnet.dev_public_subnet.id
  route_table_id = aws_route_table.dev_public_rt.id
}

# Create security group for the dev VPC
resource "aws_security_group" "dev_sg" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.dev_vpc.id
}

# create ingress rule to allow traffic from a specific IP only
resource "aws_security_group_rule" "dev_sg_rule_ingress_from_myip" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["${var.my_ip}"]
  security_group_id = aws_security_group.dev_sg.id
}

# create egress rule to allow access to all traffic towards internet
resource "aws_security_group_rule" "dev_sg_rule_egress_to_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.dev_sg.id
}

# create aws key pair using public key in your .ssh directory
resource "aws_key_pair" "dev_auth" {
  key_name   = "dev-key"
  public_key = file("~/.ssh/${var.identityfile_name}.pub")
}

# Create dev VM instance
resource "aws_instance" "dev_vm" {
  ami                    = data.aws_ami.server_ami.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.dev_auth.id
  vpc_security_group_ids = [aws_security_group.dev_sg.id]
  subnet_id              = aws_subnet.dev_public_subnet.id
  user_data              = file("templates/userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "dev-node"
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