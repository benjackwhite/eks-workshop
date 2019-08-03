# Kubernetes Workshop

This repository is the basis for a workshop on Kubernetes.

## Infrastructure

The basis of the K8s cluster is managed with Terraform under the `/tf` directory.


# Workshop

## Configuring to connect to the cluster
The files to be used during the workshop are found in `/workshop`. Before starting the participants should be given a kubectl config that can be generated using the following command

```
./scripts/generate-kubeconfig.sh http://eks-server-url.example workshop-administrator-token-ID > workshop_kubeconfig`

# Usage
KUBECONFIG=./workshop_kubeconfig kubectl get pods
```

## Workshop steps

1. Connect to cloud K8s with kubectl
2. Deploy a distributed example Deployment
3. Make our application reachable via a proxy
4. Make our application accessible via public internet (Ingress)
5. View logs of our application
6. Execute commands within our application's container (lets kill our own application)
7. Update our deployment to automatically recover from disaster
8. Scale our application up
9. Update our application and rollout the changes

11. Tidy up and delete all our resources


