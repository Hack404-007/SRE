#!/bin/sh

systemctl stop docker
rm -rf /var/cache/yum/x86_64

mkdir -p /var/cache/yum/x86_64
curl -sSL http://iares.cn/docker/download/centos7.2.1511_docker_yum_v1.12.cpio | cpio -icduv

cat >/etc/yum.repos.d/docker.repo <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=0
gpgkey=https://yum.dockerproject.org/gpg
EOF

yum -C install -y docker-engine

rm -rf /var/cache/yum/x86_64

mkdir -p /etc/docker/certs.d/registry.hundsun.com && curl -sSL http://iares.cn/docker/download/ca.crt > /etc/docker/certs.d/registry.hundsun.com/ca.crt

systemctl start docker

systemctl enable docker

