#!/bin/bash

figlet MASTER

echo "[TASK 1] Start Kubernetes Cluster"
kubeadm init --apiserver-advertise-address=$1 --pod-network-cidr=10.244.0.0/16 >> /root/kubeinit.log 2>/dev/null

echo "[TASK 2] Copy Kube Config To Vagrant User .kube Directory"
mkdir /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
chown -R root:root /root/.kube

echo "[TASK 4] Generate Join Command To Cluster For Worker Nodes"
kubeadm token create --print-join-command > /join_worker_node.sh
kubectl taint nodes --all node-role.kubernetes.io/master-

figlet WEAVENET
kubectl create -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

figlet DASHBOARD
kubectl create -f /vagrant/kube-dashboard/kubernetes-dashboard.yaml
kubectl create -f /vagrant/kube-dashboard/kubernetes-dashboard-rbac.yaml
