#!/bin/bash
# ------------------------------------
# Name:        System Performance Checker
# Version:     1.0
# Author:      Jason Savitt
# Description: Checks the system performance of a specific Kubernetes nodes.
# Notes:       - This scripts assume, that a Debian version with systemd is being utilized.
#              - This script requires root permissions to run.
# Update:      15-June-2024
# Sytax:       ./check_system_performance.sh
# Example:     ./check_system_performance.sh
# -----------------------------------

# Script Defaults
defaultTailLength=10
defaultGrepQuery="fail|warn|error|oom|dump|crash"


echo -e "${BOLD_WHITE}----------------------------------------------${RESET}"
echo -e "SYSTEM PERFORMANCE ANALYZER"
echo -e "Hostname:      $(hostname)"
echo -e "Date/Time:     $(date)"
echo -e "Linux Version: $(uname -a)"
echo -e "Uptime:        $(uptime)"
echo -e "${BOLD_WHITE}----------------------------------------------${RESET}"
echo -e "\n${BOLD_WHITE}----- Displays Storage I/O Statistics ${RESET}\n${BOLD_MAGENTA}"
#Reports per-disk input/output statistics like read/write speeds, transfers, and utilization.
iostat
echo -e "\n${BOLD_WHITE}----- Displays virtual memory usage, paging, swapping, and cache misses ${RESET}\n${BOLD_MAGENTA}"
vmstat 5 3
echo -e "\n${BOLD_YELLOW}- Notes: Additions useful commands for related troubleshooting:"
echo -e "  - Ex: vmstat -s (Displays memory statistics as well as CPU and IO event counters)"
echo -e "  - Ex: vmstat -d (Displays read/write stats for various disks)"
echo -e "  - Ex: vmstat -D (Displays read/write stats for various disks) ${RESET}\n"

