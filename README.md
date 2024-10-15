# k8s-yamls
This is a repo for all of the yaml files to use in a k8s cluster.
## k3s installation
server: curl -sfL https://get.k3s.io | K3S_NODE_NAME=potato1 sh - \
node token: sudo cat /var/lib/rancher/k3s/server/node-token \
node: curl -sfL https://get.k3s.io | K3S_URL=https://192.168.50.178:6443 K3S_TOKEN= K3S_NODE_NAME=potato sh -
