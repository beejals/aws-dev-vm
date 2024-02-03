# module input variables
variable "vm_name" {}
variable "host_os" {}
variable "ec2_instance_type" {}
variable "identityfile_name" {}
variable "vpc_subnet_id" {}
variable "github_token" {}
variable "ami_id" {}
variable "sg_ids" {}

# module outputs
output "app_public_ip" {
  value = aws_instance.app_vm.public_ip
}

# create aws key pair using public key in your .ssh directory
resource "aws_key_pair" "app_auth_key" {
  key_name   = "${var.vm_name}-key"
  public_key = file("~/.ssh/${var.identityfile_name}.pub")
}

# Create VM instance
resource "aws_instance" "app_vm" {
  ami                    = var.ami_id
  instance_type          = var.ec2_instance_type
  key_name               = aws_key_pair.app_auth_key.id
  vpc_security_group_ids = var.sg_ids
  subnet_id              = var.vpc_subnet_id
  user_data              = templatefile("${path.root}/templates/userdata.tpl", { var1 = var.github_token })

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "${var.vm_name}-node"
  }

  # update ssh config file on you local machine
  provisioner "local-exec" {
    command = templatefile("${path.root}/templates/${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip
      user         = "ubuntu",
      identityfile = "~/.ssh/${var.identityfile_name}"
    })
    interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  }
}