Docker-enabled Vagrant boxes
============================


## Purpose

Some Linux distributions don't have a pre-installed [Docker](http://www.docker.com) engine. Public Vagrant boxes (e.g., those in [Vagrant Cloud](https://vagrantcloud.com/) and [Vagrantbox.es](http://www.vagrantbox.es/)) also lack quality support for Docker. So I build these Vagrant boxes to aid my Docker development.


## For impatient

Use the following public box names (all available from [Vagrant Cloud](https://vagrantcloud.com/)):

- Debian jessie x64: [`williamyeh/debian-jessie64-docker`](https://vagrantcloud.com/williamyeh/debian-jessie64-docker) 

- Ubuntu 14.04 LTS ("Trusty") x64:

  - [`williamyeh/ubuntu-trusty64-docker`](https://vagrantcloud.com/williamyeh/ubuntu-trusty64-docker)
  
  - [`3scale/docker`](https://vagrantcloud.com/3scale/docker), a nice alternative.

- CentOS 6.5 x64:

  - (TODO) williamyeh/centos65-docker

  - [`jdiprizio/centos-docker-io`](https://vagrantcloud.com/jdiprizio/centos-docker-io), a nice alternative.


## Included software

- Docker Engine

- Docker CLI

- [Fig](http://www.fig.sh/): Fast, isolated development environments using Docker.

- [Pipework](https://github.com/jpetazzo/pipework)

- [docker-gen](https://github.com/jwilder/docker-gen)

- [dockerize](https://github.com/jwilder/dockerize)


## Build these boxes yourself

Currently, Vagrant Cloud doesn't have an *automated build*  mechanism as in the [Docker Hub](https://hub.docker.com/) ecosystem. You might not trust those boxes I've put into Vagrant Cloud; you might want more up-to-date packages in the box.

OK, you can build these boxes as follows.

First, generate a Vagrant box file:


```
# change working directory to any specific OS;
# for example, "debian-jessie"
cd debian-jessie

# build it!
./build.sh

# if successful, you'll get an 'output.box' file
ls -al
```


Then, you can use the generated box file as follows:

```
# give it a local name (e.g., "my-jessie64")
vagrant box add  --name my-jessie64  output.box

# now you'll see the box installed locally
vagrant box list

```

For live demo, see [Building a Docker-enabled Vagrant box for Debian jessie x86_64](https://asciinema.org/a/10603).



## License

Licensed under [MIT license](http://creativecommons.org/licenses/MIT/).

Copyright © 2013+ William Yeh - [https://github.com/William-Yeh](https://github.com/William-Yeh).
