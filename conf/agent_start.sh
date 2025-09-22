#!/bin/bash
echo 120 > /proc/sys/net/ipv4/tcp_keepalive_time
echo 131060 > /proc/sys/vm/max_map_count
echo 1 > /proc/sys/vm/swappiness

# MongoDB 8.0+ THP setting
## Agent MUST run as root when running inside a container
## Service requires 'privileged: true' in docker-compose.yml
echo always | tee /sys/kernel/mm/transparent_hugepage/enabled > /dev/null
echo defer+madvise | tee /sys/kernel/mm/transparent_hugepage/defrag > /dev/null
echo 0 | tee /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none > /dev/null
echo 1 | tee /proc/sys/vm/overcommit_memory > /dev/null

CONFFILE=/etc/mongodb-mms/automation-agent.config

/opt/mongodb-mms-automation/bin/mongodb-mms-automation-agent -f ${CONFFILE} \
    -pidfilepath /var/run/mongodb-mms-automation/mongodb-mms-automation-agent.pid 2>&1 \
    | /opt/mongodb-mms-automation/bin/fatallogger \
    -logfile /var/log/mongodb-mms-automation/automation-agent-fatal.log