# Developer VM Creation using Terraform Demo #
This repo is created with sample Terraform code to show how to create your own developer VM on aws.  This based on tutorial by [Derek Morgan](https://morethancertified.com/) and modified for my needs.
## Install and config ##
1. Install Terraform - https://developer.hashicorp.com/terraform/install
    * Make sure to add Terraform home directory to your PATH environment variable
2. Create access key for terraform to use to connect to aws.  Update the credentials file on your machine with the key information.  See: https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication-user.html#cli-authentication-user-configure-csv.titlecli-authentication-user-configure-file
3. Used ssh-keygen to create an ssh key pair.  The public key will be installed on the VM
    * update the identityfile_name variable in terraform.tfvars file with the correct name of your identifile
```bash
ssh-keygen -t ed25519
```
4. Point your browser to https://www.whatismyip.com/ and get the public IPv4 address and update my_ip variable value, in terraform.tfvars file, as CIDR a block e.g. 1.2.3.4/32
5. If you are using Mac or Linux to run this, update host_os variable value, in terraform.tfvars file, to linux
6. Initialize you working directory
```bash
terraform init
```
7. Run terraform plan
```bash
terraform plan
```
8. Run terraform apply
```bash
terraform apply
```
9. The output should be the public IP of your VM, use this IP to SSH to.  If the ssh config file (~/.ssh/config) is correctly updated, the following should work
```bash
ssh <app_public_ip>
```
10. Connect to your VM using ssh command from step 9 and validate proper installation of Docker Engine
```bash
docker run hello-world
```
11. Run terraform destroy to terminate your instance
```bash
terraform destroy
```
