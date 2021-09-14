#!/bin/bash

GRAFANA_VERSION=7.5.10 PLUGIN_VERSION=0.2.6
GRAFANA_HOST=localhost GRAFANA_PORT=3000

ORBITER_LISTEN=localhost:8084
PROMETHEUS_LISTEN=localhost:9090

function get_current_dir() {
    if [ $(uname) = "Darwin" ]; then
        CUR_DIR=$(dirname $(greadlink -f $0))
    else
        CUR_DIR=$(dirname $(readlink -f $0))
    fi

    echo $CUR_DIR
}

function download_and_unzip(){
    KERNEL=$1
    ARCH=$2
    VERSION=$3
    FILE=grafana-$VERSION.$KERNEL-$ARCH.tar.gz

    pushd /

    if ! [ -f $FILE ]; then
        wget https://dl.grafana.com/oss/release/$FILE
    else
        echo "$FILE already exist. skip downloading"
    fi
    tar -xvzf $FILE
    popd
}

function install(){
    VERSION=$1
    CUR_DIR=$(get_current_dir)
    GRAFANA_ROOT=/grafana-$VERSION
    sudo chown -R vagrant:vagrant $GRAFANA_ROOT 
    pushd $GRAFANA_ROOT

    mkdir -p $GRAFANA_ROOT/data/plugins
    mkdir -p $GRAFANA_ROOT/conf

    #this form of sed command works in both linux and mac
    #cp ../grafana-data/conf/defaults.ini $GRAFANA_ROOT/conf &&
        #sed -i'' -e "s/http_port = [0-9].*/http_port = $GRAFANA_PORT/" $GRAFANA_ROOT/conf/defaults.ini &&
        #cp ../grafana-data/data/* $GRAFANA_ROOT/data

    $GRAFANA_ROOT/bin/grafana-cli --homepath $GRAFANA_ROOT --pluginsDir $GRAFANA_ROOT/data/plugins plugins install simpod-json-datasource $PLUGIN_VERSION

    $GRAFANA_ROOT/bin/grafana-cli --homepath $GRAFANA_ROOT admin reset-admin-password admin

    popd
}

function update_datasource () {
    #copy for idempotent
    CUR_DIR=$(get_current_dir)
    GRAFANA_ROOT=$CUR_DIR/../grafana-$GRAFANA_VERSION

    $GRAFANA_ROOT/bin/grafana-server --homepath $GRAFANA_ROOT &
    PID=$!

    pushd $CUR_DIR/../grafana-data/datasource
    #copy for idempotent

    rm -f prometheus-cur.json &&
        cp prometheus.json prometheus-cur.json &&
        sed -i'' -e "s/\"url\":\".*\",/\"url\":\"$PROMETHEUS_LISTEN\",/" prometheus-cur.json &&
        curl -X PUT -H "Content-Type: application/json; Accept: application/json" --data "@prometheus-cur.json" -u admin:admin $GRAFANA_HOST:$GRAFANA_PORT/api/datasources/1

    rm -f orbiter-cur.json &&
        cp orbiter.json orbiter-cur.json &&
        sed -i'' -e "s/\"url\":\".*\",/\"url\":\"$ORBITER_LISTEN\",/" orbiter-cur.json &&
        curl -X PUT -H "Content-Type: application/json; Accept: application/json" --data "@orbiter-cur.json" -u admin:admin $GRAFANA_HOST:$GRAFANA_PORT/api/datasources/2

    kill $PID
    popd
}

KERNEL=$(uname)
ARCH_RAW=$(uname -m)

if [ $KERNEL = "Linux" ]; then
    KERNEL=linux
elif [ $KERNEL = "Darwin" ]; then
    KERNEL=darwin
else
    echo unknown kernel: $KERNEL. script only support Linux and Darwin
    exit;
fi

ARCH=$ARCH_RAW

if [ $ARCH_RAW = "x86_64" ]; then
    ARCH="amd64"
elif [ $ARCH_RAW = "arm64" -o $ARCH_RAW = "aarch64" ]; then
    ARCH="arm64"
else
    echo "This script only support x86_64 and arm64 architecture"
    exit;
fi


#main
download_and_unzip $KERNEL $ARCH $GRAFANA_VERSION

install $GRAFANA_VERSION

#TODO
#update_datasource


