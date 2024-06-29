#!/bin/bash
echo -e "/n${BOLD_WHITE} ----- Etcd (ControlPlane) [Last 10 Lines]${RESET}"
kubectl -n kube-system logs etcd-controlplane | tail
echo -e "/n${BOLD_WHITE} ----- API Server (ControlPlane) [Last 10 Lines]${RESET}"
kubectl -n kube-system logs kube-apiserver-controlplane | tail      
echo -e "/n${BOLD_WHITE} ----- Kube Controller (ControlPlane) [Last 10 Lines]${RESET}"
kubectl -n kube-system logs kube-controller-manager-controlplane | tail
echo -e "/n${BOLD_WHITE} ----- Kube Schuduler (ControlPlane) [Last 10 Lines]${RESET}"
kubectl -n kube-system logs kube-scheduler-controlplane | tail
echo -e "/n${BOLD_WHITE} ----- Additional Kube-System Pods with Log Files)${RESET}"
echo -e "/n${BOLD_YELLOW} - Note: Use: kubectl -n kube-system logs [podName] | tail ${RESET}"
kubectl get pods -n kube-system | grep -v controlplane
