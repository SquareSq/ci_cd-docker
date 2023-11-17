#!/bin/bash

echo "##################"
echo "Git insalation"
echo "##################"
echo ""
sudo apt update
sudo apt install git

echo ""
sh "git --version"

sleep 10
echo " "
echo "###################"
echo "Git installed"
echo "###################"

sleep 2

echo "###################"
echo "Java installation"
echo "###################"

sudo apt install fontconfig openjdk-17-jre -y

java -version
sleep 5

echo "###################"
echo "Java installed"
echo "###################"

sleep 2


echo "###################"
echo "Jenkins installation"
echo "###################"

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install jenkins -y

sudo systemctl daemon-reload
sudo systemctl start jenkins
sudo systemctl enable jenkins

jenkins --version
sleep 5

echo "###################"
echo "Jenkins installed"
echo "###################"


echo "###################"
echo "Maven installation"
echo "###################"

sudo apt install maven -y
echo " "
mvn -version

sleep 10
echo "###################"
echo "Maven installed"
echo "##################"
