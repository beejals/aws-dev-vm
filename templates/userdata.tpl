#!/bin/bash

# Add Docker's official GPG key:
sudo apt-get update -y &&
sudo apt-get install -y ca-certificates curl gnupg &&
sudo install -m 0755 -d /etc/apt/keyrings &&
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y &&

# Install docker:
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y &&
sudo usermod -aG docker ubuntu

# Install apache web server
sudo apt install apache2 -y &&
sudo systemctl start apache2 &&
sudo systemctl enable apache2 &&

# get the html source code from git and copy to /var/www/html/ directory
sudo git clone https://${var1}@github.com/beejals/web-projects.git &&
sudo cp web-projects/poster/* /var/www/html/ -f -r
