#!/bin/bash
# ------------------------------------
# Name:        Cluster Status Checker
# Version:     1.0
# Author:      Jason Savitt
# Description: Checks the status of a Kubernetes cluster
# Notes:       Includes additional references of logs files locations
#              Future version will include:
#              - The ability to filter local logs files
#              - The ability to query CNI plugin
#              - The ability to query Container Runtime
#              - Checking any system information, CPU, Memory, Storage, Network
# Update:      15-June-2024
# Sytax:       ./check_cluster.sh
# Example:     ./check_cluster.sh 
# Notes: 
# - ANSI color aliases are setup in the kubecheck.sh file
# - kubecheck.sh file is the frontend files, and should be run to control this script.
# Warning:     For testing purposes only, use at your own risk.
# -----------------------------------


# API cluster URI
clusterAddress=$(kubectl config view | grep server| awk  '{print $2}')

#if [[ $1 == "--help" ]]; then
#    echo -e "\n${BOLD_WHITE}Help Screen:${RESET}"
#    echo -e "${BOLD_WHITE}--help     - This display screen.${RESET}"
#    echo -e "${BOLD_WHITE}--logfiles - Reference: displays log file location.${RESET}"
# Obsolete (to be removed later, leaving for reference)
#elif [[ $1 == "--logfiles" ]]; then
#    echo -e "${BOLD_WHITE}\nLog Files Locations\n${RESET}"
#    echo -e "${BOLD_WHITE}- /var/log/kube-apiserver.log${RESET}"
#    echo -e "${BOLD_WHITE}  - API Server, responsible for serving the API${RESET}"
#    echo -e "${BOLD_WHITE}- /var/log/kube-scheduler.log${RESET}"
#    echo -e "${BOLD_WHITE}  - Scheduler, responsible for making scheduling decisions${RESET}"
#    echo -e "${BOLD_WHITE}- /var/log/kube-controller-manager.log{RESET}"
#    echo -e "${BOLD_WHITE}  - A component that runs most Kubernetes built-in controllers,"
#    echo -e              "    with the notable exception of scheduling (the kube-scheduler"
#    echo -e              "    handles scheduling).${RESET}"
#    echo -e "${BOLD_WHITE}- /var/log/kubelet.log${RESET}"
#    echo -e "${BOLD_WHITE}  - logs from the kubelet, responsible for running containers" 
#    echo -e              "    on the node${RESET}"
#    echo -e "${BOLD_WHITE}- /var/log/kube-proxy.log${RESET}"
#    echo -e "${BOLD_WHITE}  - logs from kube-proxy, which is responsible for directing "
#    echo -e              "    traffic to Service endpoints.${RESET}"
#else

# Displays cluster status
echo -e "\nCluster Status Checker\n----------------${RESET}"
echo -e "${BOLD_GREEN}\n----- Cluster Info\n${RESET}"
kubectl cluster-info
# Displays node cluster status
echo -e "${BOLD_GREEN}\n----- Cluster Nodes\n${RESET}${BOLD_MAGENTA}"
kubectl get nodes -o wide
echo -e "${BOLD_WHITE}\n ** Suggestion (More Info): kubectl describe node [nodeName]${RESET}"
echo -e "${BOLD_WHITE} ** Suggestion (More Info): kubectl debug node/[nodeName] -it --image=ubuntu${RESET}"
echo -e "${BOLD_WHITE}    - Deploys a pod to a node that you want to troubleshoot.${RESET}"
echo -e "${BOLD_GREEN}\n----- Cluster Pods (NS: all) [Only displays problem pods, i.e. not 'running']${RESET}\n${BOLD_MAGENTA}"
# Displays if any pods are not running correctly.
# Not working correctly
output=$(kubectl get pod -A -o wide --field-selector status.phase!=Running --all-namespaces) 
#output=$(kubectl get pods -o wide -A | grep -v Running)
#output=$(kubectl get pods -o wide -A)
echo -e "$output"
echo -e "${BOLD_WHITE}\n ** Suggestion (More Info): kubectl get pods -A${RESET}"
echo -e "${BOLD_WHITE} ** Suggestion (More Info): kubectl get all -A${RESET}"
# Displays kubernetes component status
echo -e "${BOLD_GREEN}\n----- Component Status [only displays problems, i.e. not 'ok']${RESET}\n${BOLD_MAGENTA}"
# This Component Status command is deprecated
#kubectl get componentstatus
curl -ks https://$clusterAddress/livez?verbose # | grep --color=always -ZEv " ok|livez check passed" || echo -e "  ${BOLD_YELLOW}-- No Problems Found --${RESET}"
echo -e "${BOLD_GREEN}\n----- Cluster Deployments (NS: all)${RESET}\n${BOLD_MAGENTA}"
kubectl get deployments  -A
echo -e "${BOLD_GREEN}\n----- Cluster Daemonsets (NS: all)${RESET}\n${BOLD_MAGENTA}"
kubectl get daemonsets  -A
echo -e "${BOLD_GREEN}\n----- Cluster Deployments Status${RESET}\n${BOLD_MAGENTA}"
kubectl rollout status deployment
echo -e "${BOLD_GREEN}\n----- Cluster Replicasets (NS: all)${RESET}\n${BOLD_MAGENTA}"
kubectl get replicasets  -A
echo -e "${BOLD_GREEN}\n----- Cluster Services (NS: all)${RESET}\n${BOLD_MAGENTA}"
kubectl get services -o wide -A
echo -e "${BOLD_GREEN}\n----- Cluster Endpoints (NS: all)${RESET}\n${BOLD_MAGENTA}"
kubectl get endpoints -o wide -A
echo -e "${BOLD_GREEN}\n----- Cluster Persistent Volumes (NS: all)${RESET}\n${BOLD_MAGENTA}"
kubectl get persistentvolumes -o wide -A
echo -e "${BOLD_GREEN}\n----- Cluster Persistent Volume Claims (NS: all)${RESET}\n${BOLD_MAGENTA}"
kubectl get persistentvolumeclaims -o wide -A
echo -e "${BOLD_GREEN}\n----- Cluster Events (NS: all) (Filtered) ${RESET}\n"
kubectl get events --sort-by=.metadata.creationTimestamp -A | grep --color=always -Ei "warning |fail |error " | tail || echo -e "  ${BOLD_YELLOW}-- No Problems Found --${RESET}"
echo -e "${BOLD_GREEN}\n----- Cluster Events (NS: all) (Unfiltered) ${RESET}\n${BOLD_MAGENTA}"
kubectl get events --sort-by=.metadata.creationTimestamp -A | tail || echo -e "  ${BOLD_YELLOW}-- No Problems Found --${RESET}"
echo -e "${BOLD_GREEN}\n----- System Metrics (requires 'metric-server' to be install)${RESET}\n${BOLD_MAGENTA}"
# Check if metrics-server deployment exists
metrics_server_deployment=$(kubectl get deployments -n kube-system 2>/dev/null | grep metrics-server)
if [[ -z "$metrics_server_deployment" ]]; then
    echo -e "  ${BOLD_RED}Warning: Metrics server is not installed.${RESET}"
else
    echo -e "${BOLD_CYAN}\n-- Top Nodes --${RESET}${BOLD_MAGENTA}\n"
    kubectl top nodes 
    echo -e "${BOLD_CYAN}\n-- Top Pods --${RESET}${BOLD_MAGENTA}\n"
    kubectl top pods
fi
echo -e "${BOLD_GREEN}\n----- Checking Container Processes${RESET}\n${BOLD_MAGENTA}"
if command -v docker >/dev/null 2>&1; then
    criRuntime="docker"
    docker ps 
elif command -v podman >/dev/null 2>&1; then
    criRuntime="podman"
    podman ps
fi
echo -e "${BOLD_GREEN}\n----- Additional Troubleshooting Commands:${RESET}\n"
#echo -e "${BOLD_YELLOW}- kubectl config view${RESET}"
echo -e "${BOLD_WHITE}- kubectl get pod -n nameSpace podName -o json${RESET}"
echo -e "${BOLD_WHITE}  - Displays very detailed informaiton about a running pod${RESET}"
echo -e "${BOLD_WHITE}- kubectl logs -n nameSpace podName${RESET}"
echo -e "${BOLD_WHITE}  - Displays the log information for a running pod.${RESET}"
echo -e "${BOLD_WHITE}- kubectl describe -n nameSpace podName [--events]${RESET}"
echo -e "${BOLD_WHITE}  - Displays technical cluster information about the pod.${RESET}"
echo -e "${BOLD_WHITE}- kubectl exec -it podName -n nameSpace -- bash${RESET}"
echo -e "${BOLD_WHITE}  - Allows you enter a running pod to inspect it. ${RESET}"
#echo -e "${BOLD_WHITE}- ${RESET}"
echo ""
#fi
