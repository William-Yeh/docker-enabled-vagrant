#!/bin/bash
#
# provision script; install Docker engine & some handy tools.
#
# [NOTE] run by Vagrant; never run on host OS. 
#
# @see https://docs.docker.com/installation/debian/
# @see https://github.com/jpetazzo/nsenter
# 


export DEBIAN_FRONTEND=noninteractive

# install Docker
curl -s https://get.docker.io/ | sudo sh

# add 'vagrant' user to docker group
sudo usermod -aG docker vagrant

# install nsenter
# @see https://github.com/jpetazzo/nsenter
sudo docker run -v /usr/local/bin:/target jpetazzo/nsenter

# clean up
sudo docker rm `sudo docker ps --no-trunc -a -q`
sudo docker rmi jpetazzo/nsenter
sudo docker rmi busybox
sudo apt-get clean



#
# Vagrant-specific settings below
#

# add 'vagrant' user to docker group
sudo usermod -aG docker vagrant

# zero out the free space to save space in the final image
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY


cat <<EOF  >> /home/vagrant/.bashrc
export LC_CTYPE=C.UTF-8
lsb_release -a
EOF

