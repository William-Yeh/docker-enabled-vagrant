#!/bin/bash
#
# provision script; start a miniature Kubernetes infra.
#
# [NOTE] run by Vagrant; never run on host OS. 
#
# @see https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/getting-started-guides/locally.md
# @see https://www.cloudgear.net/blog/2015/5-minutes-kubernetes-setup/
# @see https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-kubernetes-on-top-of-a-coreos-cluster
# 

readonly K8S_MASTER=127.0.0.1:8080
readonly K8S_APISERVERS=127.0.0.1:8080
readonly ETCD_SERVER=http://127.0.0.1:4001


#
# The Kubernetes Control Plane
#

echo "==> Starting etcd server..."
sudo service etcd start

echo "==> Starting k8s apiserver..."
#sudo hyperkube apiserver --service-cluster-ip-range=172.17.17.1/24 --address=127.0.0.1 --etcd_servers=$ETCD_SERVER --cluster_name=kubernetes --v=2  &
sudo hyperkube apiserver --service-cluster-ip-range=172.17.17.1/24 --address=0.0.0.0 --etcd_servers=$ETCD_SERVER --cluster_name=kubernetes --v=2  &

echo "==> Starting k8s controller..."
sudo hyperkube controller-manager --master=$K8S_MASTER --v=2  &

echo "==> Starting k8s scheduler..."
sudo hyperkube scheduler --master=$K8S_MASTER --v=2  &



#
# The Kubernetes Node
#


echo "==> Starting k8s kubelet..."
sudo kubelet --api_servers=$K8S_APISERVERS --v=2 --address=0.0.0.0 --enable_server --config=/etc/kubernetes/manifests/  &
# workaround hyperkube bug: 
# @see https://github.com/kubernetes/kubernetes/issues/8424
#sudo hyperkube kubelet --api_servers=http://127.0.0.1:8080 --v=2 --address=0.0.0.0 --enable_server --config=/etc/kubernetes/manifests/  &

echo "==> Starting k8s proxy..."
sudo hyperkube proxy --master=$K8S_MASTER --v=2  &
