#! /bin/bash

set -e

kubectl create ns argo

#kubectl -n argo port-forward deployment/argo-server 2746:2746
kubectl create rolebinding default-admin --clusterrole=admin --serviceaccount=default:default
kubectl create configmap -n argo workflow-controller-configmap --from-literal=config="containerRuntimeExecutor: pns"
kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo/v2.4.3/manifests/install.yaml

# Download the binary
curl -sLO https://github.com/argoproj/argo/releases/download/v2.12.2/argo-linux-amd64.gz

# Unzip
gunzip argo-linux-amd64.gz

# Make binary executable
chmod +x argo-linux-amd64

# Move binary to path
sudo mv ./argo-linux-amd64 /usr/bin/argo

# Test installation
argo version