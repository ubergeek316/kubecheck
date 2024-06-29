#!/bin/bash
# ------------------------------------
# Name:        Network Status Checker
# Version:     1.0
# Author:      Jason Savitt
# Description: Checks the network status of a specific Kubernetes node.
# Notes:       - This scripts assume, that a Debian version with systemd is being utilized.
#              - This script requires root permissions to run.
# Update:      15-June-2024
# Sytax:       ./check_system_network.sh
# Example:     ./check_system_network.sh
# -----------------------------------

# Script Defaults
defaultTailLength=10
defaultGrepQuery="fail|warn|error|oom|dump|crash"

echo -e "\n${BOLD_WHITE}----------------------------------------------${RESET}"
echo -e "NETWORK TROUBLESHOOTING"
echo -e "Hostname:      $(hostname)"
echo -e "Date/Time:     $(date)"
echo -e "Linux Version: $(uname -a)"
echo -e "Uptime:        $(uptime)"
echo -e "${BOLD_WHITE}----------------------------------------------${RESET}"
defaultTestDomain="example.com"
echo -e "\n${BOLD_WHITE}----- Ping Test ($defaultTestDomain) ${RESET}\n${BOLD_MAGENTA}"
timeout 10 ping -c 5 $defaultTestDomain
echo -e "\n${BOLD_WHITE}----- DNS Test ($defaultTestDomain) ${RESET}\n${BOLD_MAGENTA}"
dig $defaultTestDomain | grep -A 1 ";; ANSWER SECTION:"
echo -e "\n${BOLD_WHITE}----- Network Statistics 1a${RESET}\n${BOLD_MAGENTA}"
netstat -i
# These commands are reserved for the future
#echo -e "\n${BOLD_WHITE}----- Network Statistics 1a ${RESET}\n${BOLD_MAGENTA}"
#netstat -s
#echo -e "\n${BOLD_WHITE}----- Network Statistics 2 ${RESET}\n${BOLD_MAGENTA}"
#ip -s link
#echo -e "\n${BOLD_WHITE}----- Network Statistics 3 ${RESET}\n${BOLD_MAGENTA}"
#sar -n DEV
echo -e "\n${BOLD_WHITE}----- Bandwith Test (10MB Download)${RESET}${BOLD_MAGENTA}"
time curl -s https://link.testfile.org/PDF10MB > /dev/null
echo ""

