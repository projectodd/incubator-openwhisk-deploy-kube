# This script assumes Docker is already installed
#!/bin/bash

set -x

# download and install the wsk cli
wget -q https://github.com/apache/incubator-openwhisk-cli/releases/download/latest/OpenWhisk_CLI-latest-linux-amd64.tgz
tar xzf OpenWhisk_CLI-latest-linux-amd64.tgz
sudo cp wsk /usr/local/bin/wsk

# set docker0 to promiscuous mode
sudo ip link set docker0 promisc on

# Download and install the oc binary
sudo mount --make-shared /
sudo service docker stop
sudo sed -i 's/DOCKER_OPTS=\"/DOCKER_OPTS=\"--insecure-registry 172.30.0.0\/16 /' /etc/default/docker
sudo service docker start
wget https://github.com/openshift/origin/releases/download/v3.7.0-alpha.1/openshift-origin-client-tools-v3.7.0-alpha.1-fdbd3dc-linux-64bit.tar.gz
tar xvzOf openshift-origin-client-tools-v3.7.0-alpha.1-fdbd3dc-linux-64bit.tar.gz > oc.bin
sudo mv oc.bin /usr/local/bin/oc
sudo chmod 755 /usr/local/bin/oc

# Start OpenShift
oc cluster up

# Wait until we have a ready node in minikube
TIMEOUT=0
TIMEOUT_COUNT=60
until [ $TIMEOUT -eq $TIMEOUT_COUNT ]; do
  if [ -n "$(/usr/local/bin/oc get nodes | grep Ready)" ]; then
    break
  fi

  echo "openshift is not up yet"
  let TIMEOUT=TIMEOUT+1
  sleep 5
done

if [ $TIMEOUT -eq $TIMEOUT_COUNT ]; then
  echo "Failed to start openshift"
  exit 1
fi

echo "openshift is deployed and reachable"
/usr/local/bin/oc describe nodes
