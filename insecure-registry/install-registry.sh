#!/bin/bash
#
# provision script; install Docker Registry V2.
#
# @see https://docs.docker.com/registry/configuration/
# @see https://github.com/docker/distribution/blob/62b70f951f30a711a8a81df1865d0afeeaaa0169/Dockerfile
#


export DEBIAN_FRONTEND=noninteractive
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8


readonly REGISTRY_VERSION=2.2.0
#readonly REGISTRY_VERSION=latest
readonly REGISTRY_IMAGE=registry:$REGISTRY_VERSION

readonly REGISTRY_CONFIG_DIR=/opt/docker-registry
readonly REGISTRY_CONFIG_NAME=docker-registry-config.yml
readonly REGISTRY_CONFIG_FULLPATH=$REGISTRY_CONFIG_DIR/$REGISTRY_CONFIG_NAME
readonly REGISTRY_DBPATH=/opt/docker-registry-db



#---------------------------------------#
# prepare directory
#

mkdir -p $REGISTRY_CONFIG_DIR
mkdir -p $REGISTRY_DBPATH



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
# @see https://docs.docker.com/registry/deploying/

version: 0.1

log:
    level: debug
    fields:
        service: registry
        environment: development

storage:
    cache:
        layerinfo: inmemory
    filesystem:
        rootdirectory: $REGISTRY_DBPATH

http:
    addr: :5000
    secret: asecretforlocaldevelopment
    debug:
        addr: localhost:5001

redis:
    addr: localhost:6379
    pool:
        maxidle: 16
        maxactive: 64
        idletimeout: 300s
    dialtimeout: 10ms
    readtimeout: 10ms
    writetimeout: 10ms

notifications:
    endpoints:
        - name: local-8082
          url: http://localhost:5003/callback
          headers:
              Authorization: [Bearer <an example token>]
          timeout: 1s
          threshold: 10
          backoff: 1s
          disabled: true
        - name: local-8083
          url: http://localhost:8083/callback
          timeout: 1s
          threshold: 10
          backoff: 1s
          disabled: true
EOF_CONFIG



#---------------------------------------#
# install init script for Upstart
#

cat << EOF_INIT > /etc/init/docker-registry.conf
description "Docker Registry"

start on filesystem and started docker
stop on runlevel [!2345]

#respawn

script

    docker kill -f docker-registry  || true
    docker rm -f docker-registry    || true

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
sudo rm -f \
  /var/log/messages   \
  /var/log/lastlog    \
  /var/log/auth.log   \
  /var/log/syslog     \
  /var/log/daemon.log \
  /var/log/docker.log \
  /home/vagrant/.bash_history \
  /var/mail/vagrant           \
  || true
