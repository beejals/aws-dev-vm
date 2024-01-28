output "app_public_ip" {
  value = aws_instance.app_vm.public_ip
}

output "my_public_ip" {
  value = chomp(data.http.my_ip.response_body)
}
