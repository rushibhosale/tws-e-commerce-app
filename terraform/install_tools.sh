#!/bin/bash

# 1. Update system and install core packages (Upgraded to Java 21)
sudo apt-get update -y
sudo apt-get install -y fontconfig openjdk-21-jre wget apt-transport-https gnupg lsb-release snapd net-tools

# 2. Jenkins installation (Using the active 2026 GPG key)
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y jenkins

# 3. Docker installation
sudo apt-get install -y docker.io

# User group permissions
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins

# 4. Trivy installation (Cleans up previous duplicate entries first)
sudo rm -f /etc/apt/sources.list.d/trivy.list
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee /etc/apt/sources.list.d/trivy.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y trivy

# 5. Snap installations for AWS CLI, Helm, and Kubectl
sudo snap install aws-cli --classic
sudo snap install helm --classic
sudo snap install kubectl --classic

# 6. Reload systemd and restart services to ensure clean startup
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl restart jenkins
sudo systemctl enable jenkins
sudo systemctl enable docker

# 7. Print Final Status
echo "========================================="
echo "        Installation complete!           "
echo "========================================="
sudo systemctl --no-pager status jenkins