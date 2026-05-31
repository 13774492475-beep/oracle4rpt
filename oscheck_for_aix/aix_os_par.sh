#!/bin/bash

#timestamp=$(date +"%Y%m%d_%H%M%S")
#filename="aix_os_par_${timestamp}.txt"
filename="aix_os_par.txt"

ipqmaxlen=$(no -a | grep -E 'ipqmaxlen' | awk '{print $3}')
rfc1323=$(no -a | grep -E 'rfc1323' | awk '{print $3}')
sb_max=$(no -a | grep -E 'sb_max' | awk '{print $3}')
tcp_ephemeral_high=$(no -a | grep -E 'tcp_ephemeral_high' | awk '{print $3}')
tcp_ephemeral_low=$(no -a | grep -E 'tcp_ephemeral_low' | awk '{print $3}')
tcp_recvspace=$(no -a | grep -E 'tcp_recvspace' | awk '{print $3}')
tcp_sendspace=$(no -a | grep -E 'tcp_sendspace' | awk '{print $3}')
udp_ephemeral_high=$(no -a | grep -E 'udp_ephemeral_high' | awk '{print $3}')
udp_ephemeral_low=$(no -a | grep -E 'udp_ephemeral_low' | awk '{print $3}')
udp_recvspace=$(no -a | grep -E 'udp_recvspace' | awk '{print $3}')
udp_sendspace=$(no -a | grep -E 'udp_sendspace' | awk '{print $3}')
maxpout=$(lsattr -El sys0 -a maxpout | awk '{print $2}')
maxuproc=$(lsattr -El sys0 -a maxuproc | awk '{print $2}')
minpout=$(lsattr -El sys0 -a minpout | awk '{print $2}')
ncargs=$(lsattr -El sys0 -a ncargs | awk '{print $2}')
iocp0=$(lsdev | grep iocp | awk '{print $2}')

{
    echo "ipqmaxlen\$-\$${ipqmaxlen}"
    echo "rfc1323\$-\$${rfc1323}"
    echo "sb_max\$-\$${sb_max}"
    echo "tcp_ephemeral_high\$-\$${tcp_ephemeral_high}"
    echo "tcp_ephemeral_low\$-\$${tcp_ephemeral_low}"
    echo "tcp_recvspace\$-\$${tcp_recvspace}"
    echo "tcp_sendspace\$-\$${tcp_sendspace}"
    echo "udp_ephemeral_high\$-\$${udp_ephemeral_high}"
    echo "udp_ephemeral_low\$-\$${udp_ephemeral_low}"
    echo "udp_recvspace\$-\$${udp_recvspace}"
    echo "udp_sendspace\$-\$${udp_sendspace}"
    echo "maxpout\$-\$${maxpout}"
    echo "maxuproc\$-\$${maxuproc}"
    echo "minpout\$-\$${minpout}"
    echo "ncargs\$-\$${ncargs}"
    echo "iocp0\$-\$${iocp0}"
} > "$filename"
