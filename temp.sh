#!/bin/bash 
echo -e "kubectl get deployments\n"
kubectl get deployments
echo -e "\nkubectl get pods\n"
kubectl get pods
echo -e "\nkubectl get replicasets\n"
kubectl get replicasets
