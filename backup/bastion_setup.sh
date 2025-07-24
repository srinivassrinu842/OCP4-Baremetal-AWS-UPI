#!/bin/bash
hostnamectl set-hostname bastion
echo "${bastion_private_ip} bastion" >> /etc/hosts

# Enable IP forwarding for NAT functionality
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Setup iptables for NAT
sudo dnf install firewalld httpd haproxy git bind-utils net-tools wget bash-completion -y 
sudo systemctl enable --now firewalld.service
sudo firewall-cmd --permanent --zone=public --add-masquerade
sudo firewall-cmd --permanent --zone=public --add-rich-rule="rule family='ipv4' source address='${private_subnet_cidr_0}' accept"
sudo firewall-cmd --permanent --zone=public --add-rich-rule="rule family='ipv4' source address='${private_subnet_cidr_1}' accept"
sudo firewall-cmd --permanent --zone=public --add-rich-rule="rule family='ipv4' source address='${private_subnet_cidr_2}' accept"
sudo firewall-cmd --permanent --add-port={80,443,6443,22623,9000,8080}/tcp
sudo firewall-cmd --permanent --add-service={http,https}
sudo firewall-cmd --reload

# Selinux add the custom ports for haproxy
sudo semanage port -a -t http_port_t -p tcp 6443
sudo semanage port -a -t http_port_t -p tcp 22623

# configure haproxy
sudo cp -p /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak
sudo cat << HAPROXY_CONFIG > /etc/haproxy/haproxy.cfg
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     30000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

    # utilize system-wide crypto-policies
    ssl-default-bind-ciphers PROFILE=SYSTEM
    ssl-default-server-ciphers PROFILE=SYSTEM

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
     mode                    http
     log                     global
     option                  httplog
     option                  dontlognull
     option http-server-close
     option forwardfor       except 127.0.0.0/8
     option                  redispatch
     retries                 3
     timeout http-request    10s
     timeout queue           1m
     timeout connect         5s
     timeout client          1m
     timeout server          1m
     timeout http-keep-alive 10s
     timeout check           5s
     maxconn                 30000

frontend  kube-api
     bind *:6443
     default_backend kube-api
     mode tcp
     option tcplog

backend kube-api
     balance roundrobin
     mode tcp
     server      bootst1 ${bootstrap1_private_ip}:6443 check fall 2 rise 3
     server      master1 ${master1_private_ip}:6443 check fall 2 rise 3
     server      master2 ${master2_private_ip}:6443 check fall 2 rise 3
     server      master3 ${master3_private_ip}:6443 check fall 2 rise 3

frontend  machine-config
     bind *:22623
     default_backend machine-config
     mode tcp
     option tcplog

backend machine-config
     balance roundrobin
     mode tcp
     server      bootst1 ${bootstrap1_private_ip}:22623 check
     server      master1 ${master1_private_ip}:22623 check fall 2 rise 3
     server      master2 ${master2_private_ip}:22623 check fall 2 rise 3
     server      master3 ${master3_private_ip}:22623 check fall 2 rise 3

frontend  openshift-router-http
     bind *:80
     default_backend openshift-router-http
     mode http

backend openshift-router-http
     balance roundrobin
     mode http
     server      master1 ${master1_private_ip}:80 check fall 2 rise 3
     server      master2 ${master2_private_ip}:80 check fall 2 rise 3
     server      master3 ${master3_private_ip}:80 check fall 2 rise 3
     
     #server      wrk1 10.0.2.17:80 check fall 2 rise 3

frontend  openshift-router-https
     bind *:443
     default_backend openshift-router-https
     mode tcp
     option tcplog

backend openshift-router-https
     balance roundrobin
     mode tcp
     server      master1 ${master1_private_ip}:443 check fall 2 rise 3
     server      master2 ${master2_private_ip}:443 check fall 2 rise 3
     server      master3 ${master3_private_ip}:443 check fall 2 rise 3

     #server      wrk1 10.0.2.17:443 check fall 2 rise 3
HAPROXY_CONFIG

# enable haproxy
sudo systemctl enable --now haproxy.service

# configure httpd
sudo sed -i "s/^Listen 80$/Listen 8080/" /etc/httpd/conf/httpd.conf
sudo systemctl enable --now httpd.service

# generate SSH Keys
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/ocpupi

# download the packages 
mkdir -p ~/softwares
export MIRROR="https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp"
wget ${MIRROR}/${ocp_version}/openshift-client-linux.tar.gz -P ~/softwares
wget ${MIRROR}/${ocp_version}/openshift-install-linux.tar.gz -P ~/softwares

# extract the packages
sudo tar -xzf ~/softwares/openshift-client-linux.tar.gz -C /usr/local/bin
sudo tar -xzf ~/softwares/openshift-install-linux.tar.gz -C /usr/local/bin

# oc bash completion
sudo oc completion bash > /etc/bash_completion.d/oc
sudo openshift-install completion bash > /etc/bash_completion.d/openshift-install

# create ocp4 install directory
mkdir -p ~/ocp4
cat > ~/install-config.yaml << INSTALL_CONFIG
apiVersion: v1
baseDomain: ${domain_name}
compute:
- hyperthreading: Enabled
  name: worker
  replicas: 0
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3
metadata:
  name: ${environment}
networking:
  clusterNetworks:
  - cidr: 10.254.0.0/16
    hostPrefix: 24
  networkType: OVNKubernetes
  serviceNetwork:
  - 172.30.0.0/16
platform:
  none: {}
pullSecret: '${pull_secret}'
sshKey: '$(cat ~/.ssh/ocpupi.pub)'
INSTALL_CONFIG

# copy the install-config.yaml to ocp4 directory
cp ~/install-config.yaml ~/ocp4/install-config.yaml

# create manifests
openshift-install create manifests --dir ~/ocp4

# create ignition files
openshift-install create ignition-configs --dir ~/ocp4

# configure the httpd to hold the ignition files
sudo mkdir -p /var/www/html/ignition
sudo cp ~/ocp4/*.ign /var/www/html/ignition/
sudo restorecon -vR /var/www/html/
sudo chmod o+r /var/www/html/ignition/*.ign