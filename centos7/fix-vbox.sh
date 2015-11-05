#!/bin/bash
#
# Fix vbguest for CentOS + Docker
#

case "$PACKER_BUILDER_TYPE" in
virtualbox-iso|virtualbox-ovf)
    # fix bug: "Failed to mount folders in Linux guest. This is usually because the "vboxsf" file system is not available."
    # @see http://qiita.com/liubin/items/f03398c4be61d21878b8
    echo "==> Fixing vboxguest..."
    ver="`cat /home/vagrant/.vbox_version`";
    /opt/VBoxGuestAdditions-${ver}/init/vboxadd setup
    #mount -t vboxsf -o uid=`id -u vagrant`,gid=`getent group vagrant | cut -d: -f3` vagrant /vagrant

    umount /tmp/vbox       || true
    rm -rf /tmp/vbox       || true
    rm -f $HOME_DIR/*.iso  || true

    ;;

esac
