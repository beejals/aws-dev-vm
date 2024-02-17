
# Create a VPC, public subnet, private subnet and the route tables
module "networking" {
  source                    = "./networking"
  vpc_cidr_block            = var.vpc_cidr_block
  vpc_name                  = var.env
  public_subnet_cidr_block  = var.public_subnet_cidr_block
  private_subnet_cidr_block = var.private_subnet_cidr_block
  availability_zone         = var.availability_zone
}

# Create security group and associated rules
module "security-groups" {
  source      = "./security-groups"
  app_sg_name = var.env
  vpc_id      = module.networking.app_vpc_id
  my_ip       = chomp(data.http.my_ip.response_body)
}

# Create EC2 instance
module "dev-vm" {
  source            = "./dev-vm"
  vm_name           = var.env
  host_os           = var.host_os
  ec2_instance_type = var.ec2_instance_type
  identityfile_name = var.identityfile_name
  vpc_subnet_id     = tolist(module.networking.app_vpc_public_subnets)[0]
  github_token      = var.github_token
  ami_id            = data.aws_ami.server_ami.id
  sg_ids            = [module.security-groups.app_sg_id]
}