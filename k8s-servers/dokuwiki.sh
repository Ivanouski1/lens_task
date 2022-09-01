#!/bin/bash

helm repo add k8s-at-home https://k8s-at-home.com/charts/
helm repo update
helm install dokuwiki k8s-at-home/dokuwiki
