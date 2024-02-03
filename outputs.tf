output "app_public_ip" {
  value = module.dev-vm.app_public_ip
}

output "my_public_ip" {
  value = chomp(data.http.my_ip.response_body)
}
