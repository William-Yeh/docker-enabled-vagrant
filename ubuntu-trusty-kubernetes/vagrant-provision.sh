#!/bin/bash
#
# provision script; install Kubernetes.
#
# [NOTE] run by Vagrant; never run on host OS. 
#
# @see https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/getting-started-guides/locally.md
# 


export DEBIAN_FRONTEND=noninteractive
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

readonly ETCD_VERSION_TAG=etcd-v0.4.6-linux-amd64
readonly ETCD_TARBALL_URL=https://github.com/coreos/etcd/releases/download/v0.4.6/$ETCD_VERSION_TAG.tar.gz
#readonly ETCD_VERSION_TAG=etcd-v0.5.0-alpha.2-linux-amd64
#readonly ETCD_TARBALL_URL=https://github.com/coreos/etcd/releases/download/v0.5.0-alpha.2/$ETCD_VERSION_TAG.tar.gz


#readonly KUBERNETES_TARBALL_URL=http://storage.googleapis.com/kubernetes-releases-56726/devel/kubernetes.tar.gz
readonly KUBERNETES_GIT=https://github.com/GoogleCloudPlatform/kubernetes.git

#readonly GOLANG_TARBALL=https://storage.googleapis.com/golang/go1.3.3.linux-amd64.tar.gz



#---------------------------------------#
# fix base box
#

# update packages
sudo apt-get update
#sudo apt-get -y -q upgrade
#sudo apt-get -y -q dist-upgrade



#---------------------------------------#
# install etcd
#
# "You need an etcd somewhere in your path.
#  Get the latest release and place it in /usr/bin."
#

curl -L  $ETCD_TARBALL_URL  -o etcd.tar.gz
tar xzvf etcd.tar.gz
sudo mv $ETCD_VERSION_TAG/etcd     /usr/bin
sudo mv $ETCD_VERSION_TAG/etcdctl  /usr/bin
rm -rf  $ETCD_VERSION_TAG  etcd.tar.gz


#---------------------------------------#
# install Go binary (maybe a little old...)
#
# @see https://golang.org/doc/install
#

DEBIAN_FRONTEND=noninteractive \
    sudo apt-get install -y golang


#---------------------------------------#
# install Kubernetes 
#

DEBIAN_FRONTEND=noninteractive \
    sudo apt-get install -y net-tools

cd /opt
git clone $KUBERNETES_GIT
cd kubernetes
make



# clean up
sudo docker rm -f `sudo docker ps --no-trunc -a -q`
sudo apt-get clean
sudo rm -f \
  /var/log/messages   \
  /var/log/lastlog    \
  /var/log/auth.log   \
  /var/log/syslog     \
  /var/log/daemon.log \
  /var/log/docker.log


#---------------------------------------#
# Vagrant-specific settings below
#


# zero out the free space to save space in the final image
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY


rm -f /home/vagrant/.bash_history


sudo cat <<EOF  >> /home/vagrant/.bashrc
#export GOROOT=/usr/local/go
#export GOPATH=/opt/go
#export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
export PATH=$PATH:/opt/kubernetes/_output/local/bin/linux/amd64
EOF

