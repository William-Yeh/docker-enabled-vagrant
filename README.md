Docker-enabled Vagrant boxes
============================


## Purpose

Some Linux distributions don't have a pre-installed [Docker](http://www.docker.com) engine. Public Vagrant boxes (e.g., those in [Atlas](https://atlas.hashicorp.com/boxes/search) and [Vagrantbox.es](http://www.vagrantbox.es/)) also lack quality support for Docker. So I build these Vagrant boxes to aid my Docker development.

I also install some handy tools for Docker.


## For the impatient

Use the following public box names (all available from [Atlas](https://atlas.hashicorp.com/) service):


- Ubuntu 14.04.x LTS ("Trusty") x64:

  - [`williamyeh/ubuntu-trusty64-docker`](https://vagrantcloud.com/williamyeh/ubuntu-trusty64-docker), basically [ubuntu-14.04.3-server-amd64](http://releases.ubuntu.com/14.04/) + Docker

  - [`williamyeh/insecure-registry`](https://vagrantcloud.com/williamyeh/insecure-registry), basically `williamyeh/ubuntu-trusty64-docker` + [Docker Registry 2.x](https://github.com/docker/distribution)

- Debian 8 ("Jessie") x64:

  - [`williamyeh/debian-jessie64-docker`](https://vagrantcloud.com/williamyeh/debian-jessie64-docker), basically [debian-8.3.0-amd64](http://cdimage.debian.org/cdimage/release/8.3.0/amd64/) + Docker

  - [`williamyeh/k8s`](https://atlas.hashicorp.com/williamyeh/boxes/k8s), basically `williamyeh/debian-jessie64-docker` + Kubernetes

- CentOS 7 x64:

  - [`williamyeh/centos7-docker`](https://atlas.hashicorp.com/williamyeh/boxes/centos7-docker/), basically [CentOS 7.2](http://mirrors.kernel.org/centos/7.2.1511/) + Docker





## Included software

- Docker Engine

- Docker CLI

- [Docker Compose](https://github.com/docker/compose): Fast, isolated development environments using Docker.

- [Docker Swarm](https://github.com/docker/swarm): a Docker-native clustering system.

- [Docker Machine](https://github.com/docker/machine): Machine management for a container-centric world.

- [docker-bench-security](https://github.com/docker/docker-bench-security): a script that checks for all the automatable tests included in the [CIS Docker 1.6 Benchmark](https://benchmarks.cisecurity.org/tools2/docker/CIS_Docker_1.6_Benchmark_v1.0.0.pdf).

- [dockviz](https://github.com/justone/dockviz): Visualizing Docker data (`docker images --tree` replacement).

- [Pipework](https://github.com/jpetazzo/pipework): Software-Defined Networking for Linux Containers.

- [docker-gen](https://github.com/jwilder/docker-gen): Generate files from docker container meta-data.

- [dockerize](https://github.com/jwilder/dockerize): Utility to simplify running applications in docker containers.

- [cAdvisor](https://github.com/google/cadvisor/): Analyzes resource usage and performance characteristics of running containers.

- [weave](https://github.com/zettio/weave): creates a virtual network that connects Docker containers deployed across multiple hosts and enables their automatic discovery.

- [Docker host tools](https://github.com/William-Yeh/docker-host-tools): Some handy tools for managing Docker images and containers (also written by me).

- [Docker Registry 2.x](https://github.com/docker/distribution) (only provided in [`williamyeh/insecure-registry`](https://vagrantcloud.com/williamyeh/insecure-registry) box)

- [Kubernetes](http://kubernetes.io/) (only provided in [`williamyeh/k8s`](https://atlas.hashicorp.com/williamyeh/boxes/k8s) box)


## Build these boxes yourself

Here are steps you can follow to build these boxes on your own.


First, install the [Packer](https://www.packer.io/) tool on your host machine.

Second, pull the [Bento](https://github.com/chef/bento) submodule:

```
# pull the Bento project
git submodule init

# copy Bento stuff to sub-directories
# since Packer doesn't push soft links to Atlas (defects!)...
./copy-bento.sh
```

Third, choose the box directory of your choice:


```
# change working directory to any specific OS;
# for example, "ubuntu-trusty"
cd ubuntu-trusty
```


Now, you can either generate the Vagrant box file *on your machine*:


```
# build `ubuntu-trusty64-docker`:
packer build ubuntu-trusty64-docker.json


# build `ubuntu-trusty64-docker`, VirtualBox version only:
packer build -only=virtualbox-iso  \
       ubuntu-trusty64-docker.json


# build `ubuntu-trusty64-docker`, VirtualBox version only,
# with pre-downloaded ISO file from `file:///Volumes/ISO/`:
packer build -only=virtualbox-iso  \
       -var 'mirror=file:///Volumes/ISO/'  \
       ubuntu-trusty64-docker.json
```

you'll get an 'XXX.box' file in the `builds` directory, if successful.


Or, you can *delegate the building and hosting tasks* to [Atlas](https://atlas.hashicorp.com/):

```
# make sure the following environment variables are set:
#   ATLAS_TOKEN
#   ATLAS_USERNAME
packer push ubuntu-trusty64-docker.json
```


## Alternatives

Some nice alternatives you may try:


- Ubuntu 14.04 LTS ("Trusty") x64:

  - [`3scale/docker`](https://vagrantcloud.com/3scale/docker)


- CentOS 6.x x64:

  - [`jdiprizio/centos-docker-io`](https://vagrantcloud.com/jdiprizio/centos-docker-io)


- CoreOS x64:

  - [`yungsang/coreos` (stable)](https://atlas.hashicorp.com/yungsang/boxes/coreos)
  - [`yungsang/coreos-beta`](https://atlas.hashicorp.com/yungsang/boxes/coreos-beta)
  - [`yungsang/coreos-alpha`](https://atlas.hashicorp.com/yungsang/boxes/coreos-alpha)




## License

Licensed under [MIT license](http://creativecommons.org/licenses/MIT/).

Copyright © 2014-2016 William Yeh - [https://github.com/William-Yeh](https://github.com/William-Yeh).
