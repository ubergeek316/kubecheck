#!/bin/bash
# ------------------------------------
# Name:        System Reboot Checker
# Version:     1.0
# Author:      Jason Savitt
# Description: Checks the resaon for system reboot of a specific Kubernetes nodes.
# Notes:       - This scripts assume, that a Debian version with systemd is being utilized.
#              - This script requires root permissions to run.
# Update:      15-June-2024
# Sytax:       ./check_system_reboot.sh
# Example:     ./check_system_reboot.sh
# -----------------------------------

# Script Defaults
defaultTailLength=10
defaultGrepQuery="fail|warn|error|oom|dump|crash"

echo -e "${BOLD_WHITE}----------------------------------------------${RESET}"
echo -e "REBOOT ANALYZER"
echo -e "Hostname:      $(hostname)"
echo -e "Date/Time:     $(date)"
echo -e "Linux Version: $(uname -a)"
echo -e "Uptime:        $(uptime)"
echo -e "${BOLD_WHITE}----------------------------------------------${RESET}"
echo -e "\n${BOLD_WHITE}----- nnn ${RESET}\n${BOLD_MAGENTA}"
journalctl --list-boots | head
echo -e "\n${BOLD_WHITE}----- nnn ${RESET}\n${BOLD_MAGENTA}"
last -xF reboot shutdown | head

