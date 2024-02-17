
terraform {
  backend "s3" {
    bucket = "beejals-terraform-backend"
    key    = "aws-dev-vm/terraform.tfstate"
    region = "ca-central-1"
  }
}
