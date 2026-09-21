#!/bin/bash

# 1. Update system and install core packages (Added -y to openjdk installation)
sudo apt-get update -y
sudo apt-get install -y fontconfig openjdk-17-jre wget apt-transport-https gnupg lsb-release snapd

# 2. Jenkins installation
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y
sudo apt-get -y install jenkins

sudo systemctl start jenkins
sudo systemctl enable jenkins

# 3. Docker installation
sudo apt-get install docker.io -y

# User group permissions (Allows Jenkins and the current user to run Docker commands)
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins

sudo systemctl restart docker
sudo systemctl restart jenkins

# 4. Trivy installation (UPDATED to fix apt-key deprecation)
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list

sudo apt-get update -y
sudo apt-get install trivy -y

# 5. Snap installations for AWS CLI, Helm, and Kubectl
sudo snap install aws-cli --classic
sudo snap install helm --classic
sudo snap install kubectl --classic

echo "Installation complete!"