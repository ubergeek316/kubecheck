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

# Global Variables
defaultTailRows=10

# This section is used to setup what is necessary to get the token to access the Kubernetes API
# Checks if the secret 'default-token' is already define, if so it will not try to create it again
if ! kubectl describe secret default-token &> /dev/null; then 
    echo -e "\n${BOLD_YELLOW}Generating access to check API connections:\n${RESET}${BOLD_WHITE}"
    # Display and select the cluster name to use
    kubectl config view -o jsonpath='{"Cluster name\t|\tServer\n"}{range .clusters[*]}{.name}{"\t|\t"}{.cluster.server}{"\n"}{end}'
    read -p "Enter your cluster name you want to use (from the output above): " CLUSTER_NAME
    # Stores the cluster name for later use (does not writ)
    echo "$CLUSTER_NAME" > /tmp/check_cluster.cfg

# Create a secret in YAML to hold a token for the default service account
# The indenting of this section is on purpose because of formating in VIM
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: default-token
  annotations:
    kubernetes.io/service-account.name: default
type: kubernetes.io/service-account-token
EOF

    # Waits for the token controller to populate the secret with a token:
    while ! kubectl describe secret default-token | grep -E '^token' >/dev/null; do
      echo "Waiting for token..." >&2
      sleep 1
    done
fi

# Left for future reference in case I want to have a menu option again
#if [[ $1 == "--help" ]]; then
#    echo -e "\n${BOLD_WHITE}Help Screen:${RESET}"
#    echo -e "${BOLD_WHITE}--help     - This display screen.${RESET}"
#elif [[ $1 == "--logfiles" ]]; then
#    echo -e "${BOLD_WHITE}\nLog Files Locations\n${RESET}"

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
#curl -ks https://$clusterAddress/livez?verbose # | grep --color=always -ZEv " ok|livez check passed" || echo -e "  ${BOLD_YELLOW}-- No Problems Found --${RESET}"
# Points to the API server referring the cluster name
CLUSTER_NAME=$(cat /tmp/check_cluster.cfg)
APISERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name==\"$CLUSTER_NAME\")].cluster.server}")
# Gets the token value containing the secret token
TOKEN=$(kubectl get secret default-token -o jsonpath='{.data.token}' | base64 --decode)
# Explore the API with TOKEN
curl -X GET $APISERVER/livez?verbose --header "Authorization: Bearer $TOKEN" --insecure  | grep --color=always -ZEv " ok|livez check passed" || echo -e "  ${BOLD_YELLOW}-- No Problems Found --${RESET}"
echo -e "${BOLD_GREEN}\n----- Cluster Deployments (NS: all)${RESET}\n${BOLD_MAGENTA}"
kubectl get deployments -A | tail -n $defaultTailRows
echo -e "${BOLD_GREEN}\n----- Cluster Daemonsets (NS: all)${RESET}\n${BOLD_MAGENTA}"
kubectl get daemonsets  -A | tail -n $defaultTailRows
echo -e "${BOLD_GREEN}\n----- Cluster Deployments Status${RESET}\n${BOLD_MAGENTA}"
kubectl rollout status deployment | tail -n $defaultTailRows
echo -e "${BOLD_GREEN}\n----- Cluster Replicasets (NS: all)${RESET}\n${BOLD_MAGENTA}"
kubectl get replicasets  -A | tail -n $defaultTailRows
echo -e "${BOLD_GREEN}\n----- Cluster Services (NS: all)${RESET}\n${BOLD_MAGENTA}"
kubectl get services -o wide -A | tail -n $defaultTailRows
echo -e "${BOLD_GREEN}\n----- Cluster Endpoints (NS: all)${RESET}\n${BOLD_MAGENTA}"
kubectl get endpoints -o wide -A | tail -n $defaultTailRows
echo -e "${BOLD_GREEN}\n----- Cluster Persistent Volumes (NS: all)${RESET}\n${BOLD_MAGENTA}"
kubectl get persistentvolumes -o wide -A | tail -n $defaultTailRows
echo -e "${BOLD_GREEN}\n----- Cluster Persistent Volume Claims (NS: all)${RESET}\n${BOLD_MAGENTA}"
kubectl get persistentvolumeclaims -o wide -A | tail -n $defaultTailRows
echo -e "${BOLD_GREEN}\n----- Cluster Events (NS: all) (Filtered) ${RESET}\n"
kubectl get events --sort-by=.metadata.creationTimestamp -A | grep --color=always -Ei "warning |fail |error " | tail -n $defaultTailRows || echo -e "  ${BOLD_YELLOW}-- No Problems Found --${RESET}"
echo -e "${BOLD_GREEN}\n----- Cluster Events (NS: all) (Unfiltered) ${RESET}\n${BOLD_MAGENTA}"
kubectl get events --sort-by=.metadata.creationTimestamp -A | tail -n $defaultTailRows || echo -e "  ${BOLD_YELLOW}-- No Problems Found --${RESET}"
echo -e "${BOLD_GREEN}\n----- System Metrics (requires 'metric-server' to be install)${RESET}\n${BOLD_MAGENTA}"
# Check if metrics-server deployment exists
# To install the metrics-server
# kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# More information: https://kubernetes-sigs.github.io/metrics-server/
metrics_server_deployment=$(kubectl get deployments -n kube-system 2>/dev/null | grep metrics-server)
if [[ -z "$metrics_server_deployment" ]]; then
    echo -e "  ${BOLD_RED}Warning: Metrics server is not installed.${RESET}"
else
    echo -e "${BOLD_CYAN}\n-- Top Nodes --${RESET}${BOLD_MAGENTA}\n"
    kubectl top nodes  | tail -n $defaultTailRows
    echo -e "${BOLD_CYAN}\n-- Top Pods --${RESET}${BOLD_MAGENTA}\n"
    kubectl top pods | tail -n $defaultTailRows
fi
echo -e "${BOLD_GREEN}\n----- Checking Container Processes${RESET}\n${BOLD_MAGENTA}"
if command -v docker >/dev/null 2>&1; then
    criRuntime="docker"
    docker ps  | tail -n $defaultTailRows
elif command -v podman >/dev/null 2>&1; then
    criRuntime="podman"
    podman ps | tail -n $defaultTailRows
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
