#!/bin/bash
set -e

# your server name goes here
server=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
admin_secret_name=$(kubectl get secrets -o name | grep workshop-administrator-token)

ca=$(kubectl get $admin_secret_name -o jsonpath='{.data.ca\.crt}')
token=$(kubectl get $admin_secret_name -o jsonpath='{.data.token}' | base64 --decode)
namespace=$(kubectl get $admin_secret_name -o jsonpath='{.data.namespace}' | base64 --decode)

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