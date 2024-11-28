#!/bin/bash

install_jenkins_ubuntu() {
    sudo apt update -y
    sudo apt install fontconfig openjdk-17-jre -y
    
    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
  
    sudo apt-get update -y
    
    sudo apt-get install jenkins -y
    
    sudo systemctl start jenkins
    sudo systemctl enable jenkins


install_jenkins_fedora() {
  sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
  sudo dnf upgrade -y
# Add required dependencies for the jenkins package
  sudo dnf install fontconfig java-17-openjdk -y
  sudo dnf install jenkins -y
  sudo systemctl daemon-reload
  
  sudo systemctl start jenkins
  sudo systemctl enable jenkins


if grep -qi ubuntu /etc/os-release; then
    install_jenkins_ubuntu
elif grep -qi fedora /etc/os-release; then
    install_jenkins_fedora
else
    echo "Unsupported Operating System."
fi

else
    echo "Cannot determine the operating system. Exiting."
    exit 1
fi