#!/bin/bash
# ------------------------------------
# Name:        System Storage Cleaner
# Version:     1.0
# Author:      Jason Savitt
# Description: Frees storage on specific Kubernetes nodes.
# Notes:       - This scripts assume, that a Debian version with systemd is being utilized.
#              - This script requires root permissions to run.
# Update:      15-June-2024
# Sytax:       ./check_system_clean_storage.sh
# Example:     ./check_system_clean_storage.sh
# Warning:     For testing purposes only, use at your own risk.
# -----------------------------------

# Script Defaults
defaultTailLength=10
defaultGrepQuery="fail|warn|error|oom|dump|crash"


echo -e "${BOLD_WHITE}----------------------------------------------${RESET}"
echo -e "STORAGE CLEANUP"
echo -e "Hostname:      $(hostname)"
echo -e "Date/Time:     $(date)"
echo -e "Linux Version: $(uname -a)"
echo -e "Uptime:        $(uptime)"
echo -e "${BOLD_WHITE}----------------------------------------------${RESET}"
echo -e "\n${BOLD_WHITE}----- Automatic Storage Cleanup ${RESET}\n${BOLD_MAGENTA}"
echo -e "\n${BOLD_WHITE}- Clean feature (Deletes unused packages)${RESET}\n${BOLD_MAGENTA}"
apt-get clean -y
echo -e "\n${BOLD_WHITE}- AutoRemove feature (Removes unnecessary packages) ${RESET}\n${BOLD_MAGENTA}"
apt-get autoremove -y
echo -e "\n${BOLD_WHITE}- AutoClean feature ${RESET}\n${BOLD_MAGENTA}"
apt-get autoclean -y
echo -e "\n${BOLD_WHITE}- Cleanup old journal entries ${RESET}\n${BOLD_MAGENTA}"
journalctl --vacuum-time=3d
echo -e "\n${BOLD_YELLOW}- Notes: Additions useful commands for related troubleshooting:"
echo -e "  - Ex: journalctl --vacuum-size=10M (cleans up journal entries based on size.)"
echo -e "  - Any unnecessary application should be uninstalled."
echo -e "  - Check for older kernels that can be deleted.${RESET}\n"

