#!/bin/bash
# ------------------------------------
# Name:        Kube Checker (front-end)
# Version:     1.0
# Author:      Jason Savitt
# Description: Checks the status of a specific Kubernetes cluster or pods 
# Notes:       n/a
# Update:      27-June-2024
# Sytax:       ./kubecheck.sh [cluster|pod] [[podName] [nameSpace]]
# Example:     ./kubecheck.sh cluster
# Example:     ./kubecheck.sh pod [podName] [nameSpace] 
# -----------------------------------

# ANSI Color Aliases
# Reset color (default terminal colors)
export RESET='\033[0m'
# Foreground colors
export BOLD_BLACK='\033[1;30m'
export BOLD_RED='\033[1;31m'
export BOLD_GREEN='\033[1;32m'
export BOLD_YELLOW='\033[1;33m'
export BOLD_BLUE='\033[1;34m'
export BOLD_MAGENTA='\033[1;35m'
export BOLD_CYAN='\033[1;36m'
export BOLD_WHITE='\033[1;37m'

if [ "$1" == "cluster" ]; then 
    # Checks a kubernetes cluster
    ./check_cluster.sh
    exit
elif [ "$1" == "pod" ]; then
    # Check if a podname and namespace are being passed
    if [ ! -z $2 ]; then
        # Checks a kubernetes pod (with parameters)
        ./check_pod.sh $2 $3
    else
        # Checks a kubernetes pod (without parameters)
        ./check_pod.sh
    fi
    exit
elif [ "$1" == "cleanstorage" ]; then
    check_system_clean_storage.sh
elif [ "$1" == "network" ]; then
    check_system_network.sh
elif [ "$1" == "performance" ]; then
    check_system_performance.sh
elif [ "$1" == "processes" ]; then
    check_system_processes.sh
elif [ "$1" == "lastreboot" ]; then
    check_system_reboot.sh
elif [ "$1" == "storage" ]; then
    check_system_storage.sh
else 
    echo -e "\n${BOLD_YELLOW}Help Information:"
    echo -e "${BOLD_YELLOW}- To check a clsuter, type:"
    echo -e "${BOLD_WHITE}  kubecheck.sh cluster"
    echo -e "${BOLD_YELLOW}- To check a pod, type:"
    echo -e "${BOLD_WHITE}  kubecheck.sh pod [podName] [podName]"
    echo -e "${BOLD_YELLOW}- To frees storage by deleting temporary files and clean system resources on a node, type:"
    echo -e "${BOLD_WHITE}  kubecheck.sh cleanstorage"
    echo -e "${BOLD_YELLOW}- To check the network subsystem for errors on a node , type:"
    echo -e "${BOLD_WHITE}  kubecheck.sh network "
    echo -e "${BOLD_YELLOW}- To check performance on a node, type:"
    echo -e "${BOLD_WHITE}  kubecheck.sh performance"
    echo -e "${BOLD_YELLOW}- To check processes on a node, type:"
    echo -e "${BOLD_WHITE}  kubecheck.sh processes"
    echo -e "${BOLD_YELLOW}- To check last reboot on a node, type:"
    echo -e "${BOLD_WHITE}  kubecheck.sh lastreboot"
    echo -e "${BOLD_YELLOW}- To check storage on a node, type:"
    echo -e "${BOLD_WHITE}  kubecheck.sh storage"
    echo -e "${RESET}"
fi

