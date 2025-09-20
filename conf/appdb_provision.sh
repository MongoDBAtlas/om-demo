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


initRS &
exec "$@"