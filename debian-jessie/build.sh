#!/bin/bash

readonly BOX_FILE=debian-jessie64-docker.box
#readonly BOX_FILE=output.box


echo "===> Clean up for a fresh new environment..."
vagrant halt
vagrant destroy --force
vagrant plugin uninstall vagrant-vbguest


echo
echo "===> Install Docker and new version of VirtualBox Guest Additions..."
vagrant up
vagrant ssh -c "sudo apt-get -y install linux-headers-amd64"
vagrant plugin install vagrant-vbguest
vagrant vbguest --do install --auto-reboot


echo
echo "===> Clean up intermediate stuff..."
vagrant halt
sleep 30
vagrant up --provision


echo
echo "===> Package the outcome, and clean up host environment..."
vagrant package --output $BOX_FILE
vagrant destroy --force
