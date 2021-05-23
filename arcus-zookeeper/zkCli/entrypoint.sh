#!/bin/bash
echo "start register $ZK_ENSEMBLE, $SERVICE_CODE, $CACHENODES"
if [ -z $ZK_ENSEMBLE ]
then
    echo "ZK_ENSEMBLE is not defined"
    exit 1
fi

if [ -z $SERVICE_CODE ] ; then
    echo "service code is not defined";
    exit 1;
fi

if [ -z $CACHENODES ] ; then
    echo "cachenodes are not defined";
    exit 1;
fi

#extract first server from list
ZK_SERVER=${ZK_ENSEMBLE%%,*}

echo service code is $SERVICE_CODE

for node in ${CACHENODES//,/ }
do
    echo register cachenode $node to zk sererver $ZK_SERVER
    /apache-zookeeper-3.5.9-bin/bin/zkCli.sh -server $ZK_SERVER create /arcus 0
    /apache-zookeeper-3.5.9-bin/bin/zkCli.sh -server $ZK_SERVER create /arcus/cache_list 0
    /apache-zookeeper-3.5.9-bin/bin/zkCli.sh -server $ZK_SERVER create /arcus/cache_list/$SERVICE_CODE 0
    /apache-zookeeper-3.5.9-bin/bin/zkCli.sh -server $ZK_SERVER create /arcus/cache_server_mapping 0
    /apache-zookeeper-3.5.9-bin/bin/zkCli.sh -server $ZK_SERVER create /arcus/cache_server_mapping/$node 0
    /apache-zookeeper-3.5.9-bin/bin/zkCli.sh -server $ZK_SERVER create /arcus/cache_server_mapping/$node/$SERVICE_CODE 0
done
