Docker-enabled Vagrant boxes
============================


## Purpose

Some Linux distributions don't have a pre-installed [Docker](http://www.docker.com) engine. Public Vagrant boxes (e.g., those in [Vagrant Cloud](https://vagrantcloud.com/) and [Vagrantbox.es](http://www.vagrantbox.es/)) also lack quality support for Docker. So I build these Vagrant boxes to aid my Docker development.

I also install some handy tools for Docker.


## For the impatient

Use the following public box names (all available from [Vagrant Cloud](https://vagrantcloud.com/)):


- Ubuntu 14.04.2 LTS ("Trusty") x64:

  - [`williamyeh/ubuntu-trusty64-docker`](https://vagrantcloud.com/williamyeh/ubuntu-trusty64-docker), basically [ubuntu/trusty64](https://vagrantcloud.com/ubuntu/boxes/trusty64) + Docker - Chef - Puppet

  - [`williamyeh/insecure-registry`](https://vagrantcloud.com/williamyeh/insecure-registry), basically `williamyeh/ubuntu-trusty64-docker` + [Docker Registry 0.9](https://github.com/docker/docker-registry)

  - [`williamyeh/ubuntu-trusty64-kubernetes`](https://vagrantcloud.com/williamyeh/ubuntu-trusty64-kubernetes), basically `williamyeh/ubuntu-trusty64-docker` + Kubernetes


- Debian 8 ("Jessie") x64:

  - [`williamyeh/debian-jessie64-docker`](https://vagrantcloud.com/williamyeh/debian-jessie64-docker)



## Included software

- Docker Engine

- Docker CLI

- [Docker Compose](https://github.com/docker/compose) (was: Fig): Fast, isolated development environments using Docker.

- [Docker Swarm](https://github.com/docker/swarm): a Docker-native clustering system.

- [Docker Machine](https://github.com/docker/machine): Machine management for a container-centric world.

- [Pipework](https://github.com/jpetazzo/pipework): Software-Defined Networking for Linux Containers.

- [docker-gen](https://github.com/jwilder/docker-gen): Generate files from docker container meta-data.

- [dockerize](https://github.com/jwilder/dockerize): Utility to simplify running applications in docker containers.

- [cAdvisor](https://github.com/google/cadvisor/): Analyzes resource usage and performance characteristics of running containers

- [weave](https://github.com/zettio/weave): creates a virtual network that connects Docker containers deployed across multiple hosts and enables their automatic discovery.

- [Docker host tools](https://github.com/William-Yeh/docker-host-tools): Some handy tools for managing Docker images and containers (also written by me).

- [Docker Registry 0.9](https://github.com/docker/docker-registry) (only provided in [`williamyeh/insecure-registry`](https://vagrantcloud.com/williamyeh/insecure-registry) box)

- [Kubernetes](https://github.com/GoogleCloudPlatform/kubernetes) (only provided in [`williamyeh/ubuntu-trusty64-kubernetes`](https://vagrantcloud.com/williamyeh/ubuntu-trusty64-kubernetes) box)


## Build these boxes yourself

Currently, Atlas (was: Vagrant Cloud) doesn't have an *automated build*  mechanism similar to the [Docker Hub](https://hub.docker.com/) ecosystem. You might not trust those pre-built boxes I've uploaded into Atlas; you might want more up-to-date packages in the box before I have time updating and uploading.

Here are steps you can follow.

First, generate a Vagrant box file:


```
# change working directory to any specific OS;
# for example, "debian-jessie"
cd debian-jessie

# build it!
./build.sh

# if successful, you'll get an 'XXX.box' file
ls -al
```


Then, you can use the generated box file as follows:

```
# give it a local name (e.g., "my-jessie64")
vagrant box add  --name my-jessie64  XXX.box

# now you'll see the box installed locally
vagrant box list

```

For live demo, see [Building a Docker-enabled Vagrant box for Debian jessie x86_64](https://asciinema.org/a/10603).


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

Copyright © 2014-2015 William Yeh - [https://github.com/William-Yeh](https://github.com/William-Yeh).
