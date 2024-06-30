#!/bin/bash
# ------------------------------------
# Name:        Check Cluster Logs
# Version:     1.0
# Author:      Jason Savitt
# Description: Checks the logs of specific kube-system pods in the Kubernetes cluster.
# Notes:       n/a
# Update:      27-June-2024
# Sytax:       ./check_cluster_logs.sh 
# Example:     ./check_cluster_logs.sh
# Warning:     For testing purposes only, use at your own risk.
# -----------------------------------

# Global Variables
defaultTailRows=10
defaultGrepQuery="fail|warn|error|oom|dump|crash"

# Hold the current state of the Kubernetes clustter
echo -e "\n${BOLD_WHITE} ----- Etcd (ControlPlane) (filtered: $defaultGrepQuery) [Last 10 Lines]${RESET}\n${BOLD_MAGENTA}"
kubectl -n kube-system logs etcd-controlplane | grep --color=always -iE $defaultGrepQuery | tail -n defaultTailRows
echo -e "\n${BOLD_WHITE} ----- Etcd (ControlPlane) (Unfiltered) [Last 10 Lines]${RESET}\n${BOLD_MAGENTA}"
kubectl -n kube-system logs etcd-controlplane | tail -n defaultTailRows

# The API Server, responsible for serving the API
echo -e "\n${BOLD_WHITE} ----- API Server (ControlPlane) (filtered: $defaultGrepQuery)  [Last 10 Lines]${RESET}\n${BOLD_MAGENTA}"
kubectl -n kube-system logs kube-apiserver-controlplane | grep --color=always -iE $defaultGrepQuery | tail -n defaultTailRows
echo -e "\n${BOLD_WHITE} ----- API Server (ControlPlane) (Unfiltered) [Last 10 Lines]${RESET}\n${BOLD_MAGENTA}"
kubectl -n kube-system logs kube-apiserver-controlplane | tail -n defaultTailRows

# A component that runs most Kubernetes built-in controllers with the notable 
# exception of scheduling (the kube-scheduler handles scheduling).
echo -e "\n${BOLD_WHITE} ----- Kube Controller (ControlPlane) (filtered: $defaultGrepQuery)  [Last 10 Lines]${RESET}\n${BOLD_MAGENTA}"
kubectl -n kube-system logs kube-controller-manager-controlplane | grep --color=always -iE $defaultGrepQuery | tail -n defaultTailRows
echo -e "\n${BOLD_WHITE} ----- Kube Controller (ControlPlane) (Unfiltered) [Last 10 Lines]${RESET}\n${BOLD_MAGENTA}"
kubectl -n kube-system logs kube-controller-manager-controlplane | tail -n defaultTailRows

# Scheduler, responsible for making scheduling decisions
echo -e "\n${BOLD_WHITE} ----- Kube Schuduler (ControlPlane) (filtered: $defaultGrepQuery)  [Last 10 Lines]${RESET}\n${BOLD_MAGENTA}"
kubectl -n kube-system logs kube-scheduler-controlplane | grep --color=always -iE $defaultGrepQuery | tail -n defaultTailRows
echo -e "\n${BOLD_WHITE} ----- Kube Schuduler (ControlPlane) (Unfiltered) [Last 10 Lines]${RESET}\n${BOLD_MAGENTA}"
kubectl -n kube-system logs kube-scheduler-controlplane | tail -n defaultTailRows

# These are all the pods not marked as controlplane
echo -e "\n${BOLD_WHITE} ----- Additional Kube-System Pods with Log Files)${RESET}"
echo -e "\n${BOLD_YELLOW} - Note: Use: kubectl -n kube-system logs [podName] | tail ${RESET}\n${BOLD_MAGENTA}"
kubectl get pods -n kube-system | grep -v controlplane
echo ""

# Notes:
# The kubelet is responsible for running containers on the node
# The kube-proxy, which is responsible for directing traffic to Service endpoints.
