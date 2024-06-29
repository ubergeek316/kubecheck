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
else 
    echo "Help Information:"
    echo "- To check a clsuter, type:"
    echo "  kubecheck.sh cluster"
    echo "- To check a pod, type:"
    echo "  kubecheck.sh pod [podName] [podName]"
fi

