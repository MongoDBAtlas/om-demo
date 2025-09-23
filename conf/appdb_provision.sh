#!/bin/bash

function initRS() {
  echo ">>> Initializing replica set..."
  InitCheck=$(mongosh --eval 'rs.status()' 2>&1)
    while [[ $InitCheck == *"ECONNREFUSED"* ]]; do
        echo ">>> Waiting for mongod to start..."
        sleep 1
        InitCheck=$(mongosh --eval 'rs.status()' 2>&1)
    done
    echo ">>> "$InitCheck
    if [[ $InitCheck == *"no replset config has been received"* ]]; then
        echo ">>> Mongod is up. Proceeding with replica set initialization..."
        echo ">>> Running rs.initiate()..."
        InitCheck=$(mongosh -f /var/lib/mongo/conf/appdb_initRS.js)
        echo ">>> "$InitCheck
    fi

    InitCheck=$(mongosh -u super -p super1234 2>&1)
    echo ">>> "$InitCheck
    if [[ $InitCheck == *"Authentication failed"* ]]; then
        echo ">>> Creating 1st User..."
        while [ -z $primary ]; do
            echo ">>> Waiting for primary to be elected..."
            sleep 1
            primary=$(mongosh --eval 'db.isMaster().primary')
        done
        InitCheck=$(mongosh -f /var/lib/mongo/conf/create1stUser.js 2>&1)
        echo ">>> "$InitCheck

        echo ">>> create default users..."
        InitCheck=$(mongosh -u super -p super1234 -f /var/lib/mongo/conf/createUsers.js 2>&1)
        echo ">>> "$InitCheck
    else
        echo ">>> 1st User already exists. Skipping user creation."
    fi
  echo ">>> Replica set initialized."
}

# MongoDB common settings
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

initRS &
exec "$@"