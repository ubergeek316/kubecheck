#!/bin/bash
# ------------------------------------
# Name:        Check Cluster Logs
# Version:     1.0
# Author:      Jason Savitt
# Description: Checks the logs of specific kube-system pods in the Kubernetes cluster.
# Notes:       n/a
# Update:      27-June-2024
# Sytax:       ./kubecheck.sh 
# Example:     ./kubecheck.sh
# Warning:     For testing purposes only, use at your own risk.
# -----------------------------------

echo -e "/n${BOLD_WHITE} ----- Etcd (ControlPlane) [Last 10 Lines]${RESET}\n${BOLD_MAGENTA}"
# Hold the current state of the Kubernetes clustter
kubectl -n kube-system logs etcd-controlplane | tail
echo -e "/n${BOLD_WHITE} ----- API Server (ControlPlane) [Last 10 Lines]${RESET}\n${BOLD_MAGENTA}"
# The API Server, responsible for serving the API
kubectl -n kube-system logs kube-apiserver-controlplane | tail      
echo -e "/n${BOLD_WHITE} ----- Kube Controller (ControlPlane) [Last 10 Lines]${RESET}\n${BOLD_MAGENTA}"
# A component that runs most Kubernetes built-in controllers with the notable 
# exception of scheduling (the kube-scheduler handles scheduling).
kubectl -n kube-system logs kube-controller-manager-controlplane | tail
echo -e "/n${BOLD_WHITE} ----- Kube Schuduler (ControlPlane) [Last 10 Lines]${RESET}\n${BOLD_MAGENTA}"
# Scheduler, responsible for making scheduling decisions
kubectl -n kube-system logs kube-scheduler-controlplane | tail
echo -e "/n${BOLD_WHITE} ----- Additional Kube-System Pods with Log Files)${RESET}"
echo -e "/n${BOLD_YELLOW} - Note: Use: kubectl -n kube-system logs [podName] | tail ${RESET}\n${BOLD_MAGENTA}"
kubectl get pods -n kube-system | grep -v controlplane
echo ""
# Notes:
# The kubelet is responsible for running containers on the node
# The kube-proxy, which is responsible for directing traffic to Service endpoints.
