#!/bin/bash
echo -e "/n${BOLD_WHITE} ----- Etcd (ControlPlane) [Last 10 Lines]${RESET}"
# Hold the current state of the Kubernetes clustter
kubectl -n kube-system logs etcd-controlplane | tail
echo -e "/n${BOLD_WHITE} ----- API Server (ControlPlane) [Last 10 Lines]${RESET}"
# The API Server, responsible for serving the API
kubectl -n kube-system logs kube-apiserver-controlplane | tail      
echo -e "/n${BOLD_WHITE} ----- Kube Controller (ControlPlane) [Last 10 Lines]${RESET}"
# A component that runs most Kubernetes built-in controllers with the notable 
# exception of scheduling (the kube-scheduler handles scheduling).
kubectl -n kube-system logs kube-controller-manager-controlplane | tail
echo -e "/n${BOLD_WHITE} ----- Kube Schuduler (ControlPlane) [Last 10 Lines]${RESET}"
# Scheduler, responsible for making scheduling decisions
kubectl -n kube-system logs kube-scheduler-controlplane | tail
echo -e "/n${BOLD_WHITE} ----- Additional Kube-System Pods with Log Files)${RESET}"
echo -e "/n${BOLD_YELLOW} - Note: Use: kubectl -n kube-system logs [podName] | tail ${RESET}"
kubectl get pods -n kube-system | grep -v controlplane
# Notes:
# The kubelet is responsible for running containers on the node
# The kube-proxy, which is responsible for directing traffic to Service endpoints.
