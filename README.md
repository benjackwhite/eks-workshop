# Kubernetes Workshop

This repository is the basis for a workshop on Kubernetes.

## Infrastructure

The basis of the K8s cluster is managed with Terraform under the `/tf` directory.


# Workshop

## Configuring to connect to the cluster
The files to be used during the workshop are found in `/workshop`. Before starting the participants should be given a kubectl config that can be generated using the following command

```
./workshop/scripts/generate-kubeconfig.sh http://eks-server-url.example workshop-administrator-token-ID > workshop_kubeconfig`

# Usage
KUBECONFIG=./workshop_kubeconfig kubectl get pods
```

## Workshop steps


### Step 1: Deploy an application



