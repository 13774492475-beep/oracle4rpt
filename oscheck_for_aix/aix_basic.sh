#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="aix_basic_${timestamp}.txt"
filename="aix_basic.txt"

# Collecting information using prtconf and other commands
ip_address=$(ifconfig -a | grep 'inet ' | awk '{print $2}' | head -n 1)
auto_restart=$(prtconf | awk -F': ' '/Auto Restart/ {print $2}')
cpu_type=$(prtconf | awk -F': ' '/CPU Type/ {print $2}')
console_login=$(prtconf | awk -F': ' '/Console Login/ {print $2}')
firmware_version=$(prtconf | awk -F': ' '/Firmware Version/ {print $2}')
full_core=$(prtconf | awk -F': ' '/Full Core/ {print $2}')
good_memory_size=$(prtconf | awk -F': ' '/Good Memory Size/ {print $2}')
kernel_type=$(prtconf | awk -F': ' '/Kernel Type/ {print $2}')
lpar_info=$(prtconf | awk -F': ' '/LPAR Info/ {print $2}')
machine_serial_number=$(prtconf | awk -F': ' '/Machine Serial Number/ {print $2}' | head -n 1)
memory_size=$(prtconf | awk -F': ' '/Memory Size/ {print $2}' | head -n 1)
nx_crypto_acceleration=$(prtconf | awk -F': ' '/NX Crypto Acceleration/ {print $2}')
number_of_processors=$(prtconf | awk -F': ' '/Number Of Processors/ {print $2}')
os_time=$(date '+%Y-%m-%d %H:%M')
os_utc=$(date -u '+%Y-%m-%d %H:%M')
platform_firmware_level=$(prtconf | awk -F': ' '/Platform Firmware level/ {print $2}')
processor_clock_speed=$(prtconf | awk -F': ' '/Processor Clock Speed/ {print $2}')
processor_implementation_mode=$(prtconf | awk -F': ' '/Processor Implementation Mode/ {print $2}')
processor_type=$(prtconf | awk -F': ' '/Processor Type/ {print $2}')
processor_version=$(prtconf | awk -F': ' '/Processor Version/ {print $2}')
system_model=$(prtconf | awk -F': ' '/System Model/ {print $2}')
hostname=$(hostname)
oslevel=$(oslevel)
oslevel_s=$(oslevel -s)
uptime_info=$(uptime)

{
    echo "ip_address_linux\$-\$${ip_address}"
    echo "auto_restart_linux\$-\$${auto_restart}"
    echo "cpu_type_linux\$-\$${cpu_type}"
    echo "console_login_linux\$-\$${console_login}"
    echo "firmware_version_linux\$-\$${firmware_version}"
    echo "full_core_linux\$-\$${full_core}"
    echo "good_memory_size_linux\$-\$${good_memory_size}"
    echo "kernel_type_linux\$-\$${kernel_type}"
    echo "lpar_info_linux\$-\$${lpar_info}"
    echo "machine_serial_number_linux\$-\$${machine_serial_number}"
    echo "memory_size_linux\$-\$${memory_size}"
    echo "nx_crypto_acceleration_linux\$-\$${nx_crypto_acceleration}"
    echo "number_of_processors_linux\$-\$${number_of_processors}"
    echo "os_time_linux\$-\$${os_time}"
    echo "os_utc_linux\$-\$${os_utc}"
    echo "platform_firmware_level_linux\$-\$${platform_firmware_level}"
    echo "processor_clock_speed_linux\$-\$${processor_clock_speed}"
    echo "processor_implementation_mode_linux\$-\$${processor_implementation_mode}"
    echo "processor_type_linux\$-\$${processor_type}"
    echo "processor_version_linux\$-\$${processor_version}"
    echo "system_model_linux\$-\$${system_model}"
    echo "hostname_linux\$-\$${hostname}"
    echo "oslevel_linux\$-\$${oslevel}"
    echo "oslevel_s_linux\$-\$${oslevel_s}"
    echo "uptime_linux\$-\$${uptime_info}"
} > "$filename"
