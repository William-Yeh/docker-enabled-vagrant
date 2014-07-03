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
export LC_ALL=en_US.UTF-8


#---------------------------------------#
# fix base box
#

# fix apt source
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*

sudo cat <<APT_END  > /etc/apt/sources.list
deb http://http.debian.net/debian jessie         main contrib non-free
deb http://http.debian.net/debian jessie-updates main contrib non-free
deb http://security.debian.org    jessie/updates main contrib non-free
APT_END

# update packages
sudo apt-get update
#sudo apt-get -y -q install virtualbox-guest-utils virtualbox-guest-dkms
#sudo apt-get -y -q upgrade
#sudo apt-get -y -q dist-upgrade



#---------------------------------------#
# Docker-related stuff
#

# install Docker
curl -sL https://get.docker.io/ | sudo sh

# install nsenter
# @see https://github.com/jpetazzo/nsenter
sudo docker run -v /usr/local/bin:/target jpetazzo/nsenter

# clean up
sudo docker rm `sudo docker ps --no-trunc -a -q`
sudo docker rmi jpetazzo/nsenter
sudo docker rmi busybox
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

# add 'vagrant' user to docker group
sudo usermod -aG docker vagrant

# zero out the free space to save space in the final image
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY


rm -f /home/vagrant/.bash_history

cat <<EOF  >> /home/vagrant/.bashrc
export LC_CTYPE=C.UTF-8
lsb_release -a
EOF

