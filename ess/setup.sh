#!/bin/bash

set -e

# Update and upgrade system packages
sudo apt update && sudo apt upgrade -y

# Create directory structure
mkdir -p ~/k8s/ess
cd ~/k8s/ess

# Install k3s
curl -sfL https://get.k3s.io | sh -

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Add and update Helm repos
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install nginx ingress
helm install nginx-ingress ingress-nginx/ingress-nginx

# Get public IP
public_ip=$(curl -s https://api.ipify.org)
echo "Public IP: ${public_ip}"

# Deploy ESS matrix stack
helm upgrade --install my-release oci://ghcr.io/element-hq/ess-helm/matrix-stack \
  --version 26.2.1 \
  --values https://raw.githubusercontent.com/DrPepperMonkey/k8s-yamls/main/ess/values.yaml \
  --set matrixRTC.sfu.manualIP="${public_ip}" \
  --namespace ess \
  --create-namespace

echo "Setup complete!"
