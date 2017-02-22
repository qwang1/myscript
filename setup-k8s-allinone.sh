#!/bin/bash

# Use this script to setup a kubernetes cluster all-in-one
# Execute: source setup-k8s.sh or . setup-k8s.sh
# Author: qwang@redhat.com
# Create date: 2017.02.22
# Modify date: 

set -o nounset
set -o errexit
set -x

install_etcd()
{
  echo "============================etcd============================="
  ETCD_VER=v3.1.1
  DOWNLOAD_URL=https://github.com/coreos/etcd/releases/download
  curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /home/etcd-${ETCD_VER}-linux-amd64.tar.gz
  tar zxvf /home/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /home/
  /home/etcd-${ETCD_VER}-linux-amd64/etcd --version
  echo "export PATH=\$PATH:/home/etcd-${ETCD_VER}-linux-amd64" >> /root/.bashrc
#  source /root/.bashrc
}


install_golang()
{
  echo "============================golang============================="
  yum erase golang
  GOLANG_VER=1.8
  DOWNLOAD_URL=https://storage.googleapis.com/golang
  # User "wget" here won't cover the old dir
# wget -P /home ${DOWNLOAD_URL}/go${GOLANG_VER}.linux-amd64.tar.gz 
  curl -L ${DOWNLOAD_URL}/go${GOLANG_VER}.linux-amd64.tar.gz -o /home/go${GOLANG_VER}.linux-amd64.tar.gz
  tar zxvf /home/go${GOLANG_VER}.linux-amd64.tar.gz -C /usr/local  
  cat << EOF >> /root/.bashrc
export PATH=\$PATH:/usr/local/go/bin
export GOROOT=/usr/local/go
export PATH=\$PATH:/data/bin
EOF
#  go version
#  go get -u github.com/jteeuwen/go-bindata/go-bindata
#  source /root/.bashrc
  if [ -f "/bin/go" ]; then
    rm -rf /bin/go
  fi
  ln -s /usr/local/go/bin/go /bin/go
  go version
  go get -u github.com/jteeuwen/go-bindata/go-bindata
#  echo "export PATH=\$PATH:/data/bin" >> /root/.bashrc
  go get -u github.com/cloudflare/cfssl/cmd/cfssl
  go get -u github.com/cloudflare/cfssl/cmd/cfssljson
}


install_kubernetes()
{ 
  echo "============================kubernetes============================="
  if [ -d "/data/src/kubernetes" ]; then
    rm -rf /data/src/kubernetes
  fi
  cd /data/src
  git clone https://github.com/kubernetes/kubernetes.git
  cd /data/src/kubernetes
  hack/local-up-cluster.sh
}



install_etcd
install_golang
# install_kubernetes
