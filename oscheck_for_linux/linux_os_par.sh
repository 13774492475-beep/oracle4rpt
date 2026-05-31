#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="linux_os_par_${timestamp}.txt"
filename="linux_os_par.txt"

kernel_sem=$(/sbin/sysctl -a 2>&1 | grep "kernel.sem" | grep -v -e '-1' | awk -F '= ' '{print $2}' | awk '{print $1, $2, $3, $4}')
kernel_shmall=$(/sbin/sysctl -a 2>&1 | grep -v "permission denied" | grep kernel.shmall | awk '{print $3}')
kernel_shmmax=$(/sbin/sysctl -a 2>&1 | grep -v "permission denied" | grep kernel.shmmax | awk '{print $3}')
kernel_panic_on_oops=$(/sbin/sysctl -a 2>&1 | grep -v "permission denied" | grep kernel.panic_on_oops | awk '{print $3}')
net_core_rmem_default=$(/sbin/sysctl -a 2>&1 | grep -v "permission denied" | grep net.core.rmem_default | awk '{print $3}')
net_core_rmem_max=$(/sbin/sysctl -a 2>&1 | grep -v "permission denied" | grep net.core.rmem_max | awk '{print $3}')
net_core_wmem_default=$(/sbin/sysctl -a 2>&1 | grep -v "permission denied" | grep net.core.wmem_default | awk '{print $3}')
net_core_wmem_max=$(/sbin/sysctl -a 2>&1 | grep -v "permission denied" | grep net.core.wmem_max | awk '{print $3}')
net_ipv4_conf_all_rp_filter=$(/sbin/sysctl -a 2>&1 | grep -v "permission denied" | grep net.ipv4.conf.all.rp_filter | awk '{print $3}')
net_ipv4_conf_default_rp_filter=$(/sbin/sysctl -a 2>&1 | grep -v "permission denied" | grep net.ipv4.conf.default.rp_filter | awk '{print $3}')
vm_min_free_kbytes=$(/sbin/sysctl -a 2>&1 | grep -v "permission denied" | grep vm.min_free_kbytes | awk '{print $3}')
net_ipv4_ip_local_port_range=$(/sbin/sysctl -a 2>&1 | grep -v "permission denied" | grep net.ipv4.ip_local_port_range | awk '{print $3, $4}')
fs_file_max=$(/sbin/sysctl -a 2>&1 | grep -v "permission denied" | grep fs.file-max | awk '{print $3}')
kernel_shmmni=$(/sbin/sysctl -a 2>&1 | grep -v "permission denied" | grep kernel.shmmni | awk '{print $3}')
fs_aio_max_nr=$(/sbin/sysctl -a 2>&1 | grep -v 'permission denied' | grep fs.aio-max-nr | awk '{print $3}')

{
    echo "kernel_sem\$-\$${kernel_sem}"
    echo "kernel_shmall\$-\$${kernel_shmall}"
    echo "kernel_shmmax\$-\$${kernel_shmmax}"
    echo "kernel_panic_on_oops\$-\$${kernel_panic_on_oops}"
    echo "net_core_rmem_default\$-\$${net_core_rmem_default}"
    echo "net_core_rmem_max\$-\$${net_core_rmem_max}"
    echo "net_core_wmem_default\$-\$${net_core_wmem_default}"
    echo "net_core_wmem_max\$-\$${net_core_wmem_max}"
    echo "net_ipv4_conf_all_rp_filter\$-\$${net_ipv4_conf_all_rp_filter}"
    echo "net_ipv4_conf_default_rp_filter\$-\$${net_ipv4_conf_default_rp_filter}"
    echo "vm_min_free_kbytes\$-\$${vm_min_free_kbytes}"
    echo "net_ipv4_ip_local_port_range\$-\$${net_ipv4_ip_local_port_range}"
    echo "fs_file_max\$-\$${fs_file_max}"
    echo "kernel_shmmni\$-\$${kernel_shmmni}"
    echo "fs_aio_max_nr\$-\$${fs_aio_max_nr}"
} > "$filename"

