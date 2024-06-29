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

