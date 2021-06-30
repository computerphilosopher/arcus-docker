#!/bin/bash

# zookeeper client 3.4 and 3.5 have different path 
# if ARCUS_MEMCACHED_VERSION >= 1.13.1, you have to change client directory to
# /zookeeper-client/zookeeper-client-c
# this script recives memcached version as an argument,
# and return the proper zk version and client path.
ARCUS_MEMCACHED_VERSION=$1

IFS='.' read -r -a array <<< "${ARCUS_MEMCACHED_VERSION}"

ZK_VERSION="arcus-3.4.6"
ZK_CLIENT_PATH="/src/c"

MAJOR_VERSION=${array[0]}
MINOR_VERSION=${array[1]}

if [ $MAJOR_VERSION -eq 1 ]; then
    if [ $MINOR_VERSION -ge 13 ]; then
        ZK_VERSION="arcus-3.5.9"
        ZK_CLIENT_PATH="/zookeeper-client/zookeeper-client-c"
    fi 
elif [ $MAJOR_VERSION -ge 2 ]; then
    ZK_VERSION="arcus-3.5.9"
    ZK_CLIENT_PATH="/zookeeper-client/zookeeper-client-c"
fi

if [ "$2" == "ZK_VERSION" ]; then
   echo $ZK_VERSION
elif [ "$2" == "ZK_CLIENT_PATH" ]; then
   echo $ZK_CLIENT_PATH
fi
