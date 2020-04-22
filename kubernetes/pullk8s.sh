#!/bin/bash
:<<INFO
@File : pullk8s.sh
@Time : 2020/04/22 22:03:41
@Author : zhangtyps
@GitHub : https://github.com/zhangtyps
@Version : 1.0
@Desc : 通过阿里云国内镜像一件拉取k8s组件并批量改tag
INFO

#AMD64=1，表示拉取后缀带-amd64的镜像。当AMD64不为1时，拉取不带后缀-amd64的镜像
AMD64=1

KUBE_VERSION=v1.18.2
KUBE_PAUSE_VERSION=3.2
ETCD_VERSION=3.4.3-0
DNS_VERSION=1.6.7
username=registry.cn-hangzhou.aliyuncs.com/google_containers

if [ $AMD64 -eq 1 ];then
    AMD64='-amd64'
else
    AMD64=''
fi


images=(kube-proxy$AMD64:${KUBE_VERSION}
kube-scheduler$AMD64:${KUBE_VERSION}
kube-controller-manager$AMD64:${KUBE_VERSION}
kube-apiserver$AMD64:${KUBE_VERSION}
pause:${KUBE_PAUSE_VERSION}
etcd$AMD64:${ETCD_VERSION}
coredns:${DNS_VERSION}
    )

for image in ${images[@]}
do
    docker pull ${username}/${image}
    docker tag ${username}/${image} k8s.gcr.io/${image}
    docker rmi ${username}/${image}
    echo ''
done