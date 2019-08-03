#!/bin/bash
set -e

# your server name goes here
server=$1
# the name of the secret containing the service account token goes here
name=$2

ca=$(kubectl get secret/$name -o jsonpath='{.data.ca\.crt}')
token=$(kubectl get secret/$name -o jsonpath='{.data.token}' | base64 --decode)
namespace=$(kubectl get secret/$name -o jsonpath='{.data.namespace}' | base64 --decode)

echo "
apiVersion: v1
kind: Config
clusters:
- name: eks-workshop-cluster
  cluster:
    certificate-authority-data: ${ca}
    server: ${server}
contexts:
- name: eks-workshop
  context:
    cluster: eks-workshop-cluster
    namespace: default
    user: eks-workshop-user
current-context: eks-workshop
users:
- name: eks-workshop-user
  user:
    token: ${token}
"