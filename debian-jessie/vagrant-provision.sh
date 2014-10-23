#!/bin/bash
#
# provision script; install Docker engine & some handy tools.
#
# [NOTE] run by Vagrant; never run on host OS. 
#
# @see https://docs.docker.com/installation/debian/
# 


export DEBIAN_FRONTEND=noninteractive
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8


#---------------------------------------#
# fix base box
#

# update packages
sudo apt-get update
#sudo apt-get -y -q upgrade
#sudo apt-get -y -q dist-upgrade



#---------------------------------------#
# Docker-related stuff
#

# install Docker
curl -sL https://get.docker.io/ | sudo sh


# install Fig
# @see http://www.fig.sh/install.html
curl -o fig -L https://github.com/docker/fig/releases/download/1.0.0/fig-`uname -s`-`uname -m` 
chmod a+x fig
sudo mv fig /usr/local/bin


# install Pipework
# @see https://github.com/jpetazzo/pipework
curl -o pipework -L https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework
chmod a+x pipework
sudo mv pipework /usr/local/bin


# install docker-gen
# @see https://github.com/jwilder/docker-gen
curl -o docker-gen.tar.gz -L https://github.com/jwilder/docker-gen/releases/download/0.3.4/docker-gen-linux-amd64-0.3.4.tar.gz
tar xvzf docker-gen.tar.gz
sudo chown root docker-gen
sudo chgrp root docker-gen
sudo mv docker-gen /usr/local/bin
rm *.tar.gz


# install dockerize
# @see https://github.com/jwilder/dockerize
curl -o dockerize.tar.gz -L https://github.com/jwilder/dockerize/releases/download/v0.0.1/dockerize-linux-amd64-v0.0.1.tar.gz
sudo -xzvf dockerize.tar.gz
sudo chown root dockerize
sudo chgrp root dockerize
sudo mv dockerize /usr/local/bin
rm *.tar.gz


# clean up
sudo docker rm `sudo docker ps --no-trunc -a -q`
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


rm -f /home/vagrant/.bash_history  /var/mail/vagrant

sudo cat <<HOSTNAME > /etc/hostname
localhost
HOSTNAME

cat <<EOF  >> /home/vagrant/.bashrc
export PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
export LC_CTYPE=C.UTF-8
lsb_release -a
EOF

