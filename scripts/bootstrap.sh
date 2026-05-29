#!/usr/bin/env bash

set -euo pipefail

echo "======================================"
echo " SkillPulse DevOps Bootstrap"
echo "======================================"

sudo apt-get update -y

sudo apt-get install -y \
curl \
wget \
git \
vim \
jq \
unzip \
make \
tree \
apt-transport-https \
ca-certificates \
gnupg \
lsb-release \
software-properties-common

echo "======================================"
echo " Installing Docker"
echo "======================================"

if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
fi

sudo usermod -aG docker ubuntu

echo "======================================"
echo " Installing kubectl"
echo "======================================"

if ! command -v kubectl >/dev/null 2>&1; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s \
https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
fi

echo "======================================"
echo " Installing k3s"
echo "======================================"

if ! command -v k3s >/dev/null 2>&1; then
  curl -sfL https://get.k3s.io | sh -
fi

sudo chmod 644 /etc/rancher/k3s/k3s.yaml

mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown ubuntu:ubuntu ~/.kube/config

echo "======================================"
echo " Installing Helm"
echo "======================================"

if ! command -v helm >/dev/null 2>&1; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

echo "======================================"
echo " Installing Terraform"
echo "======================================"

if ! command -v terraform >/dev/null 2>&1; then
  wget -O- https://apt.releases.hashicorp.com/gpg \
| gpg --dearmor \
| sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com \
$(lsb_release -cs) main" \
| sudo tee /etc/apt/sources.list.d/hashicorp.list

  sudo apt update
  sudo apt install terraform -y
fi

echo "======================================"
echo " Installing Ansible"
echo "======================================"

sudo apt install ansible -y

echo "======================================"
echo " Installing GitHub CLI"
echo "======================================"

if ! command -v gh >/dev/null 2>&1; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
| sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg

  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

  echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
https://cli.github.com/packages stable main" \
| sudo tee /etc/apt/sources.list.d/github-cli.list

  sudo apt update
  sudo apt install gh -y
fi

echo "======================================"
echo " Installing Trivy"
echo "======================================"

if ! command -v trivy >/dev/null 2>&1; then
  sudo apt install wget apt-transport-https gnupg lsb-release -y

  wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key \
| gpg --dearmor \
| sudo tee /usr/share/keyrings/trivy.gpg >/dev/null

  echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] \
https://aquasecurity.github.io/trivy-repo/deb \
$(lsb_release -cs) main" \
| sudo tee /etc/apt/sources.list.d/trivy.list

  sudo apt update
  sudo apt install trivy -y
fi

echo "======================================"
echo " Installing yq"
echo "======================================"

sudo wget -qO /usr/local/bin/yq \
https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64

sudo chmod +x /usr/local/bin/yq

echo "======================================"
echo " Installing ArgoCD CLI"
echo "======================================"

sudo curl -sSL -o /usr/local/bin/argocd \
https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

sudo chmod +x /usr/local/bin/argocd

echo "======================================"
echo " Installing GitLeaks"
echo "======================================"

wget https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_linux_x64.tar.gz

tar -xzf gitleaks_linux_x64.tar.gz

sudo mv gitleaks /usr/local/bin/

rm -f gitleaks_linux_x64.tar.gz LICENSE README.md

echo "======================================"
echo " Installing k9s"
echo "======================================"

curl -sS https://webinstall.dev/k9s | bash

echo "======================================"
echo " Installing stern"
echo "======================================"

curl -fsSL https://raw.githubusercontent.com/stern/stern/master/install.sh | bash

echo "======================================"
echo " Validation"
echo "======================================"

docker --version
kubectl version --client
helm version
terraform version
ansible --version
gh --version
trivy --version
argocd version --client
gitleaks version

echo "======================================"
echo " Bootstrap completed successfully"
echo "======================================"
