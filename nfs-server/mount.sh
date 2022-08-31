#!/bin/bash

sudo apt update
sudo mkdir /home/k8s_share
sudo chown -R ubuntu:ubuntu /home/k8s_share/
sudo chmod 777 /home/k8s_share
sudo apt-get install nfs-kernel-server -y
sudo chmod 666 /etc/exports
sudo echo /home/k8s_share *(rw,no_root_squash,insecure,async,no_subtree_check) >> /etc/exports
sudo exportfs -ra
sudo systemctl restart nfs-kernel-server
