#!/bin/bash

# ------------------------------------
# Name:        Kube Checker (front-end)
# Version:     1.0
# Author:      Jason Savitt
# Description: Checks the status of a specific Kubernetes cluster or pods 
# Notes:       n/a
# Update:      27-June-2024
# Sytax:       ./kube_check.sh [cluster|pod] [[podName] [nameSpace]]
# Example:     ./kube_check.sh cluster
# Example:     ./kube_check.sh pod [podName] [nameSpace] 
# -----------------------------------

if [ "$1" == "cluster" ]; then 
    # Checks a kubernetes cluster
    ./check_cluster.sh
    exit
elif [ "$1" == "pod" ]; then
    # Check if a podname and namespace are being passed
    if [ -z $2 ]; then
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
    echo "  kube_check.sh cluster"
    echo "- To check a pod, type:"
    echo "  kube_check.sh pod [podName] [podName]"
fi

