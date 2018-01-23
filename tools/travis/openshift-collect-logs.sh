#!/bin/bash

set -x

SCRIPTDIR=$(cd $(dirname "$0") && pwd)
ROOTDIR="$SCRIPTDIR/../../"

cd $ROOTDIR

echo "Gathering logs to upload to https://app.box.com/v/openwhisk-travis-logs"

mkdir logs

# Logs from all the pods
oc logs -lname=couchdb >& logs/couchdb.log
oc logs -lname=zookeeper >& logs/zookeeper.log
oc logs -lname=kafka >& logs/kafka.log
oc controller-0 >& logs/controller-0.log
oc logs controller-1 >& logs/controller-1.log
oc logs -lname=invoker -c docker-pull-runtimes >& logs/invoker-docker-pull.log
oc logs -lname=invoker -c invoker >& logs/invoker-invoker.log
oc logs -lname=nginx >& logs/nginx.log
oc logs jobs/install-routemgmt >& logs/routemgmt.log
oc logs jobs/install-catalog >& logs/catalog.log
oc get pods -o wide --show-all >& logs/all-pods.txt
