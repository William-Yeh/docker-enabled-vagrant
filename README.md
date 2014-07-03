Docker-enabled Vagrant boxes
============================


## Purpose

Some Linux distributions don't have [Docker](http://www.docker.com) engine pre-installed. Public Vagrant boxes (e.g., [Vagrant Cloud](https://vagrantcloud.com/) and [Vagrantbox.es](http://www.vagrantbox.es/)) also lack quality support for Docker. So I build these Vagrant boxes to aid my Docker development.


## For impatient

Use the following public box names (all available from [Vagrant Cloud](https://vagrantcloud.com/)):

- [`williamyeh/debian-jessie64-docker`](https://vagrantcloud.com/williamyeh/debian-jessie64-docker): Debian jessie x64

- (TODO) Ubuntu 14.04 LTS ("Trusty") x64

- (TODO) CentOS 6.5 x64





## Build these boxes yourself

Currently, Vagrant Cloud doesn't have a *automated build*  mechanism as in the [Docker Hub](https://hub.docker.com/) ecosystem. If you don't trust Vagrant Cloud, therefore, you can build these boxes as follows.

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

Licensed under the incredibly [permissive](http://en.wikipedia.org/wiki/Permissive_free_software_licence) [MIT license](http://creativecommons.org/licenses/MIT/).

Copyright © 2013+ William Yeh - [https://github.com/William-Yeh](https://github.com/William-Yeh).
