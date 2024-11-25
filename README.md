# k8s-yamls
This is a repo for all of the yaml files to use in a k8s cluster.
## K3S Installation
Server: curl -sfL https://get.k3s.io | K3S_NODE_NAME=potato1 sh - \
Node Token: sudo cat /var/lib/rancher/k3s/server/node-token \
Agent: curl -sfL https://get.k3s.io | K3S_URL=https://10.0.0.16:6443 K3S_TOKEN= K3S_NODE_NAME=potato sh -
### Uninstall K3S
Server: $ /usr/local/bin/k3s-uninstall.sh \
Agent: $  /usr/local/bin/k3s-agent-uninstall.sh
## Helm Instructions
### Install Helm
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
$ chmod 700 get_helm.sh \
$ ./get_helm.sh 
### Configure Helm
$ sudo su \
$ export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
### Happy Helming
