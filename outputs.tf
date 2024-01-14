output "app_public_ip" {
  value = aws_instance.app_vm.public_ip
}
