#!/bin/bash

#filename="crs_stats_${timestamp}.txt" # 如果需要时间戳时启用
filename="crs_stats.txt" # 固定文件名

crsctl stat res -t > "$filename"

