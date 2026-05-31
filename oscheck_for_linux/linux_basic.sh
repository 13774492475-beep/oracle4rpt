#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="linux_basic_${timestamp}.txt"
filename="linux_basic.txt"

ip_linux=$(ifconfig -a | grep 'inet ' | awk '{print $2}' | head -n 1)
kernel_version=$(cat /proc/version | awk '{print $3}')
boot_time=$(who -b | awk '{print $3,$4,$5}')
locale_encoding=$(locale | grep LANG= | cut -d '=' -f2)
os_version=$(cat /etc/redhat-release)
hostname=$(hostname)
selinux_status=$(/usr/sbin/getenforce)
firewall_status=$(systemctl status firewalld | awk '/Active:/ {print $2}')
uptime=$(uptime)
current_time=$(date '+%Y-%m-%d %H:%M')
hugepages=$(grep nr_hugepages /etc/sysctl.conf | wc -l)
ntp_status=$(ps -ef | grep ntpd.pid | grep -v 'grep' | wc -l)

{
    echo "ip\$-\$${ip_linux}"
    echo "kernel_version\$-\$${kernel_version}"
    echo "boot_time\$-\$${boot_time}"
    echo "locale_encoding\$-\$${locale_encoding}"
    echo "os_version\$-\$${os_version}"
    echo "hostname\$-\$${hostname}"
    echo "selinux_status\$-\$${selinux_status}"
    echo "firewall_status\$-\$${firewall_status}"
    echo "uptime\$-\$${uptime}"
    echo "current_time\$-\$${current_time}"
    echo "hugepages\$-\$${hugepages}"
    echo "ntp_status\$-\$${ntp_status}"
} > "$filename"
