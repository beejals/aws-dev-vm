# module input variables
variable "app_sg_name" {}
variable "vpc_id" {}
variable "my_ip" {}

# module output variables
output "app_sg_id" {
  value = aws_security_group.app_sg.id
}

# Create security group for the VPC
resource "aws_security_group" "app_sg" {
  name        = "${var.app_sg_name}_sg"
  description = "${var.app_sg_name} security group"
  vpc_id      = var.vpc_id
}

# create ingress rule for SSH traffic and restrict access from my public IP
resource "aws_security_group_rule" "app_sg_rule_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.my_ip}/32"]
  security_group_id = aws_security_group.app_sg.id
}

# create ingress rule for HTTP traffic
resource "aws_security_group_rule" "app_sg_rule_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.app_sg_name == "prod" ? ["0.0.0.0/0"] : ["${var.my_ip}/32"]
  security_group_id = aws_security_group.app_sg.id
}

# create ingress rule for HTTPS traffic
resource "aws_security_group_rule" "app_sg_rule_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.app_sg_name == "prod" ? ["0.0.0.0/0"] : ["${var.my_ip}/32"]
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