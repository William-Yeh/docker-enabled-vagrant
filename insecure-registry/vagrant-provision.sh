#!/bin/bash
#
# provision script; install Docker Registry.
#
# [NOTE] run by Vagrant; never run on host OS.
#
# @see https://docs.docker.com/registry/configuration/
# @see https://github.com/docker/distribution/blob/62b70f951f30a711a8a81df1865d0afeeaaa0169/Dockerfile
#


export DEBIAN_FRONTEND=noninteractive
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8


readonly REGISTRY_VERSION=2
#readonly REGISTRY_VERSION=latest
readonly REGISTRY_IMAGE=registry:$REGISTRY_VERSION

readonly REGISTRY_CONFIG_DIR=/opt/docker-registry
readonly REGISTRY_CONFIG_NAME=docker-registry-config.yml
readonly REGISTRY_CONFIG_FULLPATH=$REGISTRY_CONFIG_DIR/$REGISTRY_CONFIG_NAME
readonly REGISTRY_DBPATH=/opt/docker-registry-db



#---------------------------------------#
# prepare directory
#

mkdir $REGISTRY_CONFIG_DIR
mkdir $REGISTRY_DBPATH



#---------------------------------------#
# pull docker-registry image
#

docker pull $REGISTRY_IMAGE



#---------------------------------------#
# install config file
#

cat << EOF_CONFIG > $REGISTRY_CONFIG_FULLPATH
# Registry Configuration
# @see https://docs.docker.com/registry/configuration/

version: 0.1

log:
    level: debug
    formatter: text

storage:
    filesystem:
        rootdirectory: /opt/docker-registry-db
    cache:
        layerinfo: inmemory

http:
    addr: localhost:5000
    secret: asecretforlocaldevelopment
    debug:
        addr: localhost:5001

auth:
    silly:
        realm: silly-realm
        service: silly-service

EOF_CONFIG



#---------------------------------------#
# install init script for Upstart
#

cat << EOF_INIT > /etc/init/docker-registry.conf
description "Docker Registry"

start on filesystem and started docker
stop on runlevel [!2345]

respawn

script

    docker run -d  \
        --name docker-registry    \
        --restart=always          \
        -p 80:5000  -p 5001:5001  \
        -v $REGISTRY_CONFIG_DIR:/conf         \
        -v $REGISTRY_DBPATH:$REGISTRY_DBPATH  \
        $REGISTRY_IMAGE  /conf/$REGISTRY_CONFIG_NAME

end script

EOF_INIT



# clean up
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
