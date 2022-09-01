#!/bin/bash

sudo apt-get update -y

#runtime
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system
sudo apt-get update && sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
#sudo systemctl status containerd

# Installing kubeadm, kubelet and kubectl
sudo swapoff -a
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet=1.23.0-00 kubeadm=1.23.0-00 kubectl=1.23.0-00
sudo apt-mark hold kubelet kubeadm kubectl

# Initialize the Cluster
sudo kubeadm init --kubernetes-version 1.23.0 --v=5 #--pod-network-cidr 192.168.0.0/16 


USER=ubuntu

sudo mkdir -p /home/$USER/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/$USER/.kube/config
sudo chown $(id -u):$(id -g) /home/$USER/.kube/config
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
sudo chmod +r /home/$USER/.kube/config

#Command fot join nodes to the master,does after deploy manual
# kubeadm token create --print-join-command

# Git
sudo apt-get install git

# Initialize Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
sudo chmod +x get_helm.sh
./get_helm.sh
sudo helm repo add stable https://charts.helm.sh/stable 


# NFS for clients
sudo apt update
sudo apt-get install nfs-common
