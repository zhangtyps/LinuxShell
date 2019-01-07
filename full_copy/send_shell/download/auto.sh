#!/bin/bash
useradd wuxianproxy
#设置密码 
echo "wuxianproxy" | passwd --stdin wuxianproxy
#赋予超级权限
echo "wuxianproxy    ALL=(ALL)       NOPASSWD:ALL" >>/etc/sudoers
cp -r /root/* /home/wuxianproxy
#修改SSHD配置，禁止root直接登录
sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
#重启sshd
/bin/systemctl restart sshd.service
#安装openssl
yum install openssl.x86_64 openssl-devel.x86_64 -y
#安装squid
yum install squid -y
#关闭防火墙
systemctl stop firewalld.service
#设置squid 端口号为3389 
sed -i 's/^http_port .*/http_port 3389/' /etc/squid/squid.conf
#重启
systemctl restart squid.service
systemctl enable squid.service
systemctl disable firewalld.service
#修改时区
mv /etc/localtime /etc/localtime.bak
ln -s /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
yum install  -y ntp ntpdate
ntpdate cn.pool.ntp.org
hwclock --systohc

