env                       = "dev"
host_os                   = "windows"
identityfile_name         = "dev_vm"
vpc_cidr_block            = "10.10.0.0/16"
public_subnet_cidr_block  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidr_block = ["10.10.3.0/24", "10.10.4.0/24"]
availability_zone         = ["ca-central-1a", "ca-central-1b"]
ec2_instance_type         = "t2.micro"