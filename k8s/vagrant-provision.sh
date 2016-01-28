#!/bin/bash
#
# provision script; install Docker engine, Kubernetes & some handy tools.
#
# [NOTE] run by Vagrant; never run on host OS. 
#
# @see https://docs.docker.com/installation/debian/
# @see https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/getting-started-guides/locally.md
# @see https://github.com/kubernetes/kubernetes/blob/v1.1.0/docs/getting-started-guides/scratch.md


export DEBIAN_FRONTEND=noninteractive
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8


readonly ETCD_VERSION=v2.2.2
readonly ETCD_VERSION_TAG=etcd-$ETCD_VERSION-linux-amd64
readonly ETCD_TARBALL_URL=https://github.com/coreos/etcd/releases/download/$ETCD_VERSION/$ETCD_VERSION_TAG.tar.gz

readonly KUBERNETES_VERSION=v1.1.2
readonly KUBERNETES_TARBALL_URL=https://github.com/GoogleCloudPlatform/kubernetes/releases/download/$KUBERNETES_VERSION/kubernetes.tar.gz


readonly COMPOSE_VERSION=1.5.1
readonly MACHINE_VERSION=v0.5.1

readonly DOCKVIZ_VERSION=v0.3
readonly DOCKVIZ_EXE_URL=https://github.com/justone/dockviz/releases/download/$DOCKVIZ_VERSION/dockviz_linux_amd64

readonly DOCKERGEN_VERSION=0.4.3
readonly DOCKERGEN_TARBALL=docker-gen-linux-amd64-$DOCKERGEN_VERSION.tar.gz

readonly DOCKERIZE_VERSION=v0.0.4
readonly DOCKERIZE_TARBALL=dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz



#==========================================================#

#
# error handling
#

do_error_exit() {
    echo { \"status\": $RETVAL, \"error_line\": $BASH_LINENO }
    exit $RETVAL
}

trap 'RETVAL=$?; echo "ERROR"; do_error_exit '  ERR
trap 'RETVAL=$?; echo "received signal to stop";  do_error_exit ' SIGQUIT SIGTERM SIGINT


#---------------------------------------#
# fix base box
#

sudo cat <<-HOSTNAME > /etc/hostname
  localhost
HOSTNAME

cat <<-EOBASHRC  >> /home/vagrant/.bashrc
  export PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
  export LC_CTYPE=C.UTF-8
EOBASHRC


# update packages
#sudo apt-get update
sudo apt-get install -y curl unzip
#sudo apt-get -y -q upgrade
#sudo apt-get -y -q dist-upgrade


#==========================================================#


#---------------------------------------#
# Docker-related stuff
#

# install Docker
curl -sL https://get.docker.io/ | sudo sh

# add 'vagrant' user to docker group
sudo gpasswd -a vagrant docker
#sudo usermod -aG docker vagrant


# configure for systemd
cp /tmp/docker.service  /lib/systemd/system/
cp /tmp/docker.socket   /lib/systemd/system/

# enabled when booting
sudo systemctl enable docker
sudo systemctl start  docker


# enable memory and swap accounting
sed -i -e \
  's/^GRUB_CMDLINE_LINUX=.+/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/' \
  /etc/default/grub
sudo update-grub

# enable UFW forwarding
sed -i -e \
  's/^DEFAULT_FORWARD_POLICY=.+/DEFAULT_FORWARD_POLICY="ACCEPT"/' \
  /etc/default/ufw  \
  || true
sudo sysctl -w net.ipv4.ip_forward=1
cat << EOF_UFW >> /etc/sysctl.conf

# enable UFW forwarding for Docker
net.ipv4.ip_forward=1

EOF_UFW
#sudo ufw reload



#---------------------------------------#
# install etcd
#

curl -sSL  $ETCD_TARBALL_URL  -o etcd.tar.gz
tar xzvf etcd.tar.gz
sudo mv $ETCD_VERSION_TAG/etcd     /usr/local/bin
sudo mv $ETCD_VERSION_TAG/etcdctl  /usr/local/bin
rm -rf  $ETCD_VERSION_TAG  etcd.tar.gz

# configure for systemd
cp /tmp/etcd.service  /lib/systemd/system/
sudo systemctl enable etcd



#---------------------------------------#
# install kubernetes
#

K8S_EXE_LIST=("hyperkube" "kube-apiserver" "kube-controller-manager" "kubectl" "kubelet" "kube-proxy" "kube-scheduler" "linkcheck")

curl -sSL  $KUBERNETES_TARBALL_URL  -o k8s.tar.gz
tar zxvf k8s.tar.gz
tar zxvf kubernetes/server/kubernetes-server-linux-amd64.tar.gz
for i in "${K8S_EXE_LIST[@]}" ; do
    EXECUTABLE=$i
    sudo  mv  kubernetes/server/bin/$EXECUTABLE  /usr/local/bin
done


rm -rf  k8s.tar.gz
cp /tmp/start-k8s.sh  /opt/
sudo chmod a+x /opt/*.sh


#---------------------------------------#
# install cAdvisor for kubelet
# @see http://www.dasblinkenlichten.com/installing-cadvisor-and-heapster-on-bare-metal-kubernetes/
#
# also: workaround hyperkube bug 
# @see https://github.com/kubernetes/kubernetes/issues/8424
#

sudo mkdir -p /etc/kubernetes/manifests/
cp /tmp/cadvisor.manifest  /etc/kubernetes/manifests/





# install Docker Compose
# @see http://docs.docker.com/compose/install/
curl -o docker-compose -L https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m`
chmod a+x docker-compose
sudo mv docker-compose /usr/local/bin


# install Docker Machine
# @see https://docs.docker.com/machine/
curl -o docker-machine.zip -L https://github.com/docker/machine/releases/download/$MACHINE_VERSION/docker-machine_linux-amd64.zip
unzip docker-machine.zip
rm docker-machine.zip
chmod a+x docker-machine*
sudo mv docker-machine* /usr/local/bin


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



# install weave
# @see https://github.com/zettio/weave
curl -o weave -L https://github.com/zettio/weave/releases/download/latest_release/weave
sudo chmod a+x  weave
sudo chown root weave
sudo chgrp root weave
sudo mv weave /usr/local/bin
# preload images
sudo weave setup



# install Docker-Host-Tools
# @see https://github.com/William-Yeh/docker-host-tools
DOCKER_HOST_TOOLS=( docker-rm-stopped  docker-rmi-repo  docker-inspect-attr )
for item in "${DOCKER_HOST_TOOLS[@]}"; do
  curl -o /usr/local/bin/$item  -sSL https://raw.githubusercontent.com/William-Yeh/docker-host-tools/master/$item
  chmod a+x /usr/local/bin/$item
done




#
# de-duplicate ID for Swarm
# @see https://github.com/docker/swarm/issues/563
# @see https://github.com/docker/swarm/issues/362
#
rm -f /etc/docker/key.json  || true


# clean up
sudo docker rm `sudo docker ps --no-trunc -a -q`  || true
sudo docker rmi -f busybox  || true

sudo apt-get clean
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
