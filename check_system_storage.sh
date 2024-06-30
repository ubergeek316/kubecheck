#!/bin/bash
# ------------------------------------
# Name:        Storage Status Checker
# Version:     1.0
# Author:      Jason Savitt
# Description: Checks the storage status of a specific Kubernetes node.
# Notes:       - This scripts assume, that a Debian version with systemd is being utilized.
#              - This script requires root permissions to run.
# Update:      15-June-2024
# Sytax:       ./check_system_storage.sh
# Example:     ./check_system_storage.sh
# Warning:     For testing purposes only, use at your own risk.
# -----------------------------------

# Script Defaults
defaultTailLength=10
defaultGrepQuery="fail|warn|error|oom|dump|crash"


echo -e "${BOLD_WHITE}----------------------------------------------${RESET}"
echo -e "STORAGE TROUBLESHOOTING"
echo -e "Hostname:      $(hostname)"
echo -e "Date/Time:     $(date)"
echo -e "Linux Version: $(uname -a)"
echo -e "Uptime:        $(uptime)"
echo -e "${BOLD_WHITE}----------------------------------------------${RESET}"
echo -e "\n${BOLD_WHITE}----- Finds the 10 largest files${RESET}\n${BOLD_MAGENTA}"
du -h --max-depth=1  / 2> /dev/null | sort -h -r | head -n 10
# Additional searches for research purposes
#find / -maxdepth 1 -type d -mindepth 1 -exec du -hs {} \; 2> /dev/null
#find / -type f -size +1024k
#find / -size +50000  -exec ls -lahg {} \;
#find / -size +50M -type f -exec du -h {} \; | sort -n
echo -e "\n${BOLD_WHITE}----- Storage Utilization (Filterd: '/dev' only)${RESET}\n"
df -h | grep "/dev" | grep -v "loop"
# Checks for old kernel version to remove
dpkg --get-selections | grep linux-image
echo -e "\n${BOLD_YELLOW}- Notes: Additions useful commands for related troubleshooting:"
echo "  - apt-get remove --purge linux-image-X.X.XX-XX-generic (Delete old kernel versions)\n${RESET}"
echo -e "\n${BOLD_WHITE}- Journal Disk Usage${RESET}\n${BOLD_MAGENTA}"
journalctl --disk-usage
echo -e "\n${BOLD_WHITE}----- Displays Block Device ${RESET}\n${BOLD_MAGENTA}"
# Displays block devices, prints file system type.
lsblk -f
echo -e "\n${BOLD_YELLOW}- Notes: Additions useful commands for related troubleshooting:"
echo "  - Ex: blkid /dev/sda3 (Finds or print block device properties)"
echo "  - Ex: file -sL /dev/sda3 (Identifies file type, reading of block or character files, and follows of symlinks)\n${RESET}"
echo -e "\n${BOLD_WHITE}----- Display Disk Usage of: Temp, Cache, Snaps, and Logs ${RESET}\n${BOLD_MAGENTA}"
echo "- /var/tmp directory"
du -h /var/tmp | sort -h -r | head -n 10
echo "- /var/cashe directory"
du -h /var/cache | sort -h -r | head -n 10
echo "- /var/lib/snapd/snaps"
du -h /var/lib/snapd/snaps | sort -h -r | head -n 10
echo "- /var/log/"
# Checks for large log Files
du -h /var/log | sort -h -r | head -n 10
echo -e "\n${BOLD_WHITE}----- Display any Crash Dumps ${RESET}\n${BOLD_MAGENTA}"
ls -l /var/lib/systemd/coredump/
# Note: If this 'coredumpctl' is installed it can be used to display the coredumps
# - To install it, type: apt install systemd-coredump
echo -e "\n${BOLD_WHITE}----- Displays the Partion Information ${RESET}\n${BOLD_MAGENTA}"
parted -l
echo ""
# Archived for now, too verbose, looking for ways to utilize these better.
#echo -e "\n${BOLD_WHITE}----- Displays File System Mounts ${RESET}\n${BOLD_MAGENTA}"
#mount
#echo -e "\n${BOLD_WHITE}- Displays the FSTAB file ${RESET}\n${BOLD_MAGENTA}"
#cat /etc/fstab

