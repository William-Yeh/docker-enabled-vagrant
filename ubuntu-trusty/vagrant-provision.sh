#!/bin/bash
#
# provision script; install Docker engine & some handy tools.
#
# [NOTE] run by Vagrant; never run on host OS. 
#
# @see https://docs.docker.com/installation/ubuntulinux/
# 


export DEBIAN_FRONTEND=noninteractive
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8


readonly FIG_VERSION=1.0.1

readonly DOCKERGEN_VERSION=0.3.6
readonly DOCKERGEN_TARBALL=docker-gen-linux-amd64-$DOCKERGEN_VERSION.tar.gz

readonly DOCKERIZE_VERSION=v0.0.2
readonly DOCKERIZE_TARBALL=dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz


#---------------------------------------#
# fix base box
#

# disable the warning "Your environment specifies an invalid locale"
sudo touch /var/lib/cloud/instance/locale-check.skip


# update packages
sudo apt-get update
#sudo apt-get -y -q upgrade
#sudo apt-get -y -q dist-upgrade



#---------------------------------------#
# Docker-related stuff
#

# install Docker
curl -sL https://get.docker.io/ubuntu/ | sudo sh

# enable memory and swap accounting
sed -i -e \
  's/^GRUB_CMDLINE_LINUX=.+/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/' \
  /etc/default/grub
sudo update-grub

# enable UFW forwarding
sed -i -e \
  's/^DEFAULT_FORWARD_POLICY=.+/DEFAULT_FORWARD_POLICY="ACCEPT"/' \
  /etc/default/ufw
#sudo ufw reload


#
# override "insecure-registry" error for private registry to ease testing
# @see http://stackoverflow.com/a/27163607/714426
#
cat << EOF_REGISTRY >> /etc/default/docker

# allow HTTP access to private registry "registry.com"
DOCKER_OPTS="--insecure-registry registry.com"
#DOCKER_OPTS="--insecure-registry 10.0.0.0/24 --insecure-registry registry.com"

EOF_REGISTRY



# install Fig
# @see http://www.fig.sh/install.html
curl -o fig -L https://github.com/docker/fig/releases/download/$FIG_VERSION/fig-`uname -s`-`uname -m` 
chmod a+x fig
sudo mv fig /usr/local/bin


# install Pipework
# @see https://github.com/jpetazzo/pipework
curl -o pipework -L https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework
chmod a+x pipework
sudo mv pipework /usr/local/bin


# install docker-gen
# @see https://github.com/jwilder/docker-gen
curl -o docker-gen.tar.gz -L https://github.com/jwilder/docker-gen/releases/download/$DOCKERGEN_VERSION/$DOCKERGEN_TARBALL
tar xvzf docker-gen.tar.gz
sudo chown root docker-gen
sudo chgrp root docker-gen
sudo mv docker-gen /usr/local/bin
rm *.tar.gz


# install dockerize
# @see https://github.com/jwilder/dockerize
curl -o dockerize.tar.gz -L https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/$DOCKERIZE_TARBALL
tar xzvf dockerize.tar.gz
sudo chown root dockerize
sudo chgrp root dockerize
sudo mv dockerize /usr/local/bin
rm *.tar.gz


# clean up
sudo docker rm `sudo docker ps --no-trunc -a -q`
sudo docker rmi busybox
sudo apt-get autoremove -y chef puppet
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

