#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="linux_hardware_${timestamp}.txt"
filename="linux_hardware.txt"

cpu_model=$(grep "model name" /proc/cpuinfo | head -n 1 | cut -d':' -f2 | sed 's/^[[:space:]]*//' | tr -s ' ')
total_memory=$(awk '/Mem:/ {print $2"M"}' <(free -m))
physical_cpu_count=$(grep -c "physical id" /proc/cpuinfo)
os_bit_depth=$(uname -m)
cpu_frequency=$(awk -F: '/CPU MHz/ {printf "%.2fGHz\n", $2/1000}' <(lscpu))
logical_cpu_count=$(nproc)

{
    echo "cpu_model\$-\$${cpu_model}"
    echo "total_memory\$-\$${total_memory}"
    echo "physical_cpu_count\$-\$${physical_cpu_count}"
    echo "os_bit_depth\$-\$${os_bit_depth}"
    echo "cpu_frequency\$-\$${cpu_frequency}"
    echo "logical_cpu_count\$-\$${logical_cpu_count}"
} > "$filename"
