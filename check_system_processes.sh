#!/bin/bash
# ------------------------------------
# Name:        System Status Checker
# Version:     1.0
# Author:      Jason Savitt
# Description: Checks the system status of a specific Kubernetes nodes.
# Notes:       - This scripts assume, that a Debian version with systemd is being utilized.
#              - This script requires root permissions to run.
# Update:      15-June-2024
# Sytax:       ./check_system_processes.sh
# Example:     ./check_system_processes.sh
# Warning:     For testing purposes only, use at your own risk.
# -----------------------------------

# Script Defaults 
defaultTailLength=10
defaultGrepQuery="fail|warn|error|oom|dump|crash"

echo -e "\n${BOLD_WHITE}----------------------------------------------${RESET}"
echo -e "SYSTEM TROUBLESHOOTING:"
echo -e "Hostname:      $(hostname -f)"
echo -e "Date/Time:     $(date)"
echo -e "Linux Version: $(uname -a)"
echo -e "Uptime:        $(uptime)"
echo -e "${BOLD_WHITE}----------------------------------------------${RESET}"
echo -e "\n${BOLD_WHITE}----- Checking System Journal (filtered: $defaultGrepQuery) ${RESET}\n"
journalctl --since "1 hour ago" | grep --color=always -iE $defaultGrepQuery | tail -n $defaultTailLength
echo -e "\n${BOLD_WHITE}----- Checking System Service (filtered: $defaultGrepQuery)${RESET}\n${BOLD_MAGENTA}"
# Only displays failed system services
systemctl list-units --state=failed
# Saving the following commands for experiments in future releases of the script
#systemctl list-units --no-pager | grep --color=always -iE $defaultGrepQuery | tail -n $defaultTailLength
#systemctl list-units | grep kubelet.service
#systemctl status docker.service
#systemctl status kubelet.service
#systemctl status containerd.service
#systemctrl | grep --color=always -iE $defaultGrepQuery | tail -n $defaultTailLength
echo -e "\n${BOLD_WHITE}----- Checking System Message (filtered: $defaultGrepQuery)${RESET}\n$"
dmesg -t | grep --color=always -iE $defaultGrepQuery | tail -n $defaultTailLength
echo -e "\n${BOLD_WHITE}----- Checking System Logs [OLD] (filtered: $defaultGrepQuery)${RESET}\n"
cat /var/log/syslog | grep --color=always -iE $defaultGrepQuery | tail -n $defaultTailLength
echo -e "\n${BOLD_WHITE}----- Checking Free Memory ${RESET}\n${BOLD_MAGENTA}"
free -h
echo -e "\n${BOLD_WHITE}----- Top Running Processes (Top 10 Process) ${RESET}\n${BOLD_MAGENTA}"
top -b | head -n 15
echo -e "\n${BOLD_WHITE}----- Checking Free Storage (Filtered) ${RESET}\n${BOLD_MAGENTA}"
df -h | grep "/dev" | grep -v "loop"
echo -e "\n${BOLD_WHITE}----- Checking CRONTAB (Background Processes) ${RESET}\n${BOLD_MAGENTA}"
crontab -l
echo ""


# Other useful diagnostic tools:
# htop
# iftop

#echo -e "\n${BOLD_WHITE}----- nnn ${RESET}\n${BOLD_MAGENTA}"
#echo -e "\n${BOLD_WHITE}----- nnn ${RESET}\n${BOLD_MAGENTA}"
