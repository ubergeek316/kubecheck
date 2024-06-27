#!/bin/bash

# ------------------------------------
# Name:        Pod Status Checker
# Version:     1.0
# Author:      Jason Savitt
# Description: Checks the status of a specific Kubernetes pods
# Notes:       n/a
# Update:      15-June-2024
# Sytax:       ./check_pod.sh podName [nameSpace]
# Example:     ./check_pod.sh storage-provisioner kube-system
# -----------------------------------

# ANSI Color Aliases
# Reset color (default terminal colors)
RESET='\033[0m'
# Foreground colors
BOLD_BLACK='\033[1;30m'
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'
BOLD_MAGENTA='\033[1;35m'
BOLD_CYAN='\033[1;36m'
BOLD_WHITE='\033[1;37m'

if [[ $1 == "--help" ]]; then
    echo -e "\n${BOLD_WHITE}Help Screen:${RESET}"
    echo -e "\n${BOLD_WHITE}./check_pod podName nameSpace${RESET}"
elif [[ -z $1 || "$1" == "" ]]; then 
    # Display a menu of related running pods
    # Note: ** need to fix the namespace feature **
    source check_pod_select.sh
    exit
else
    # Displays pod status
    echo -e "\nPod Status Checker\n----------------${RESET}"
    # Assigns the podName parameter to a name variable
    resourceName=$1
    # Assigns the nameSpace parameter a 'default' value
    nameSpace="default"
    # if the nameSpace parameter is NOT empty, it assigns it the value of nameSpace parameter
    if [[ ! -z $2 ]]; then 
        nameSpace=$2
    fi
    echo -e "\n${BOLD_WHITE}----- Display Pod${RESET}\n${BOLD_MAGENTA}"
    kubectl get pod $resourceName -n $nameSpace -o wide
    echo -e "\n${BOLD_WHITE}----- Describe Pod (nodeaffinity)${RESET}\n${BOLD_MAGENTA}"
    kubectl describe pod $resourceName -n $nameSpace # | grep --color=always -iEz "error|warn|fail|true|false"
    echo -e "\n${BOLD_WHITE}----- Display Pod Events${RESET}\n${BOLD_MAGENTA}"
    kubectl get events --field-selector involvedObject.name=$resourceName -n $nameSpace
    echo -e "\n${BOLD_WHITE}----- Display Pod Logs${RESET}\n${BOLD_MAGENTA}"
    kubectl logs $resourceName -n $nameSpace # | grep --color=always -iEz "error|warn|fail|true|false"
    echo -e "\n${BOLD_WHITE}----- Display Pod YAML${RESET}\n${BOLD_MAGENTA}"
    kubectl get pod $resourceName -n $nameSpace -o yaml
fi
# Figures out the CRI runtime
if command -v docker >/dev/null 2>&1; then
    criRuntime="docker"
elif command -v podman >/dev/null 2>&1; then
    criRuntime="podman"
fi
echo -e "${BOLD_GREEN}\n----- Additional Pod Troubleshooting Commands:${RESET}\n"
echo -e "${BOLD_WHITE}- $criRuntime ps${RESET}"
echo -e "${BOLD_WHITE}- $criRuntime logs containerID${RESET}"
echo -e "${BOLD_WHITE}- $criRuntime inspect containerID${RESET}"
echo -e "${BOLD_WHITE}- $criRuntime port containerID${RESET}"
echo -e "${BOLD_WHITE}- $criRuntime top containerID${RESET}"
echo -e "${BOLD_WHITE}- $criRuntime stats${RESET}"
echo -e "${BOLD_WHITE}- $criRuntime info${RESET}"
echo -e "${BOLD_WHITE}- $criRuntime events${RESET}"
echo -e ""
