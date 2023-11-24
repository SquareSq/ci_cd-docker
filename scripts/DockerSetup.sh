#!/bin/bash

echo #########################
echo "System update"
echo #########################

sudo apt update

echo #########################
eho "Ok"
echo #########################
sleep 3



echo #########################
echo "Docker instllation"
echo #########################

# Add Docker's official GPG key:
sudo apt install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update


# Installing latest version
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y


echo #########################
docker --version
echo #########################
sleep 3

# Adding user to a docker group
sudo groupadd docker
sudo usermod -aG docker $USER

echo #########################
echo "Docker installed :)"
echo #########################

