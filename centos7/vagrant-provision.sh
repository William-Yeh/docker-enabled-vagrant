#!/bin/bash
#
# provision script; install Docker engine & some handy tools.
#
# @see https://docs.docker.com/installation/centos/
#


export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8


readonly COMPOSE_VERSION=1.4.0
readonly MACHINE_VERSION=v0.4.0

readonly DOCKVIZ_VERSION=v0.2.1
readonly DOCKVIZ_EXE_URL=https://github.com/justone/dockviz/releases/download/$DOCKVIZ_VERSION/dockviz_linux_amd64

readonly DOCKERGEN_VERSION=0.4.0
readonly DOCKERGEN_TARBALL=docker-gen-linux-amd64-$DOCKERGEN_VERSION.tar.gz

readonly DOCKERIZE_VERSION=v0.0.2
readonly DOCKERIZE_TARBALL=dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

readonly CADVISOR_VERSION=0.16.0
readonly CADVISOR_EXE_URL=https://github.com/google/cadvisor/releases/download/$CADVISOR_VERSION/cadvisor


#==========================================================#

# check if docker has been isntalled...
which docker
if [ "$?" -eq 0 ]; then

    sudo yum clean all
    sudo rm -f \
            /var/log/vboxadd-*.log  \
            /var/log/VBoxGuestAdditions*.log

    # zero out the free space to save space in the final image
    sudo dd if=/dev/zero of=/EMPTY bs=1M
    sudo rm -f /EMPTY


    rm -f /home/vagrant/.bash_history  /var/mail/vagrant

    sudo cat <<-HOSTNAME > /etc/hostname
    localhost
HOSTNAME

    cat <<-EOBASHRC  >> /home/vagrant/.bashrc
    export PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
    export LC_CTYPE=en_US.UTF-8
    cat /etc/redhat-release
    uname -a
EOBASHRC

    exit 0
fi

#==========================================================#


#---------------------------------------#
# fix base box
#


# update packages
sudo yum -y update
#sudo yum -y -q upgrade



#---------------------------------------#
# Docker-related stuff
#

# install Docker
curl -sL https://get.docker.io/ | sudo sh

# add 'vagrant' user to "docker" group
sudo usermod -aG docker vagrant

# configure for docker
sed -i -e "s/^# INSECURE_REGISTRY=.*$/INSECURE_REGISTRY='--insecure-registry registry.com'/"  /etc/sysconfig/docker

# enabled when booting
sudo systemctl enable docker
sudo systemctl start  docker


# enable UFW forwarding
sudo sysctl -w net.ipv4.ip_forward=1
cat << EOF_UFW >> /etc/sysctl.conf

# enable UFW forwarding for Docker
net.ipv4.ip_forward=1

EOF_UFW
#sudo ufw reload





# install Docker Compose (was: Fig)
# @see http://docs.docker.com/compose/install/
curl -o docker-compose -L https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m`
chmod a+x docker-compose
sudo mv docker-compose /usr/local/bin


# install Docker Machine
# @see https://docs.docker.com/machine/
curl -o docker-machine -L https://github.com/docker/machine/releases/download/$MACHINE_VERSION/docker-machine_linux-amd64
chmod a+x docker-machine
sudo mv docker-machine /usr/local/bin


# install dockviz
curl -o /usr/local/bin/dockviz -L $DOCKVIZ_EXE_URL
chmod a+x /usr/local/bin/dockviz


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


# install swarm
sudo docker pull swarm


# install docker-bench-security
docker pull diogomonica/docker-bench-security
cat << EOF_BENCH_SECURITY > /usr/local/bin/docker-bench-security
#!/bin/sh

exec docker run -it --label docker-bench-security="" \
    --net host --pid host \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /usr/lib/systemd:/usr/lib/systemd  \
    -v /etc:/etc \
    diogomonica/docker-bench-security

EOF_BENCH_SECURITY
chmod a+x /usr/local/bin/docker-bench-security


# install cAdvisor
curl -o /usr/local/bin/cadvisor -L $CADVISOR_EXE_URL
chmod a+x /usr/local/bin/cadvisor
docker pull google/cadvisor:latest

# configure for systemd
cp /vagrant/cadvisor.service  /lib/systemd/system/
sudo systemctl enable cadvisor



# install weave
# @see https://github.com/zettio/weave
curl -o weave -L https://github.com/zettio/weave/releases/download/latest_release/weave
sudo chmod a+x  weave
sudo chown root weave
sudo chgrp root weave
sudo mv weave /usr/local/bin
# preload images
sudo /usr/local/bin/weave setup



# install Docker-Host-Tools
# @see https://github.com/William-Yeh/docker-host-tools
DOCKER_HOST_TOOLS=( docker-rm-stopped  docker-rmi-repo  docker-inspect-attr )
for item in "${DOCKER_HOST_TOOLS[@]}"; do
  curl -o /usr/local/bin/$item  -sSL https://raw.githubusercontent.com/William-Yeh/docker-host-tools/master/$item
  chmod a+x /usr/local/bin/$item
done



# fix bug: "Failed to mount folders in Linux guest. This is usually because the "vboxsf" file system is not available."
# @see http://qiita.com/liubin/items/f03398c4be61d21878b8
#sudo yum -y install kernel-devel gcc
#sudo /etc/init.d/vboxadd setup



#
# de-duplicate ID for Swarm
# @see https://github.com/docker/swarm/issues/563
# @see https://github.com/docker/swarm/issues/362
#
rm -f /etc/docker/key.json  || true


# clean up
sudo docker rm `sudo docker ps --no-trunc -a -q`  || true
sudo docker rmi -f busybox  || true
sudo yum -y clean all
sudo rm -f \
  /home/vagrant/*.sh       \
  /home/vagrant/.vbox_*    \
  /home/vagrant/.veewee_*  \
  /var/log/messages   \
  /var/log/lastlog    \
  /var/log/auth.log   \
  /var/log/syslog     \
  /var/log/daemon.log \
  /var/log/docker.log


#---------------------------------------#
# Vagrant-specific settings below
#

