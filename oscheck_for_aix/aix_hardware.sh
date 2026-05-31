#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="aix_hardware_${timestamp}.txt"
filename="aix_hardware.txt"

cpu_model=$(lsattr -El proc0 | grep "type" | awk '{print $2}')
total_memory=$(prtconf | grep "Memory Size" | head -n 1 | awk -F: '{print $2}' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
physical_cpu_count=$(lsdev -Cc processor | grep Available | wc -l | tr -d ' ')
os_bit_depth=$(getconf KERNEL_BITMODE)
cpu_frequency=$(prtconf | grep "Processor Clock Speed" | head -n 1 | awk -F: '{print $2}' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
logical_cpu_count=$(lsdev -Cc processor | grep Available | wc -l | tr -d ' ')

{
    echo "cpu_model_aix\$-\$${cpu_model}"
    echo "total_memory_aix\$-\$${total_memory}"
    echo "physical_cpu_count_aix\$-\$${physical_cpu_count}"
    echo "os_bit_depth_aix\$-\$${os_bit_depth}"
    echo "cpu_frequency_aix\$-\$${cpu_frequency}"
    echo "logical_cpu_count_aix\$-\$${logical_cpu_count}"
} > "$filename"
