#!/bin/bash
# ------------------------------------
# Name:        System Status Checker
# Version:     1.0
# Author:      Jason Savitt
# Description: Checks the system status of a specific Kubernetes node.
# Notes:       - This scripts assume, that a Debian version with systemd is being utilized.
#              - This script requires root permissions to run.
# Update:      15-June-2024
# Sytax:       ./check_system.sh
# Example:     ./check_system.sh
# -----------------------------------
# There are currently the following areas, each of these sections will be broken up into their own script
# - System (OS, Services, RAM, CPU, Process)
# - Networking
# - Storage
# Utilitiies
# - Clean up storage

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


echo -e "${BOLD_WHITE}----------------------------------------------${RESET}"
echo -e "STORAGE TROUBLESHOOTING"
echo -e "Hostname:      $(hostname)"
echo -e "Date/Time:     $(date)"
echo -e "Linux Version: $(uname -a)"
echo -e "Uptime:        $(uptime)"
echo -e "${BOLD_WHITE}----------------------------------------------${RESET}"
echo -e "\n${BOLD_WHITE}----- Finds the 10 largest files${RESET}\n${BOLD_MAGENTA}"
du -h --max-depth=1  / 2> /dev/null | sort -n -h | head -n 10
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


# Other useful diagnostic tools:
# htop
# iftop

#echo -e "\n${BOLD_WHITE}----- nnn ${RESET}\n${BOLD_MAGENTA}"
#echo -e "\n${BOLD_WHITE}----- nnn ${RESET}\n${BOLD_MAGENTA}"
