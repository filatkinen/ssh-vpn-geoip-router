#!/bin/bash
#initial setup 
USER_REMOTE="fenych"


apt-get update -y
apt-get upgrade -y

apt remove ufw -y

iptables -F
iptables -t mangle -F
iptables -t raw -F
iptables -Z
iptables -X

iptables -A INPUT -i tun+ -j ACCEPT
iptables -A INPUT -i ppp+ -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p icmp  -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 3128 -j ACCEPT
iptables -A INPUT -p gre -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -s 192.168.0.0/16 -j MASQUERADE
iptables -P INPUT DROP
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

apt install iptables-persistent -y 
netfilter-persistent save

apt install mc -y
apt install git -y


#uncomment net.ipv4.ip_forward=1
sed -i '/^#.*net.ipv4.ip_forward=1/s/^#//' /etc/sysctl.conf

# Tur off ipv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf


sysctl -p



sed -i '/^#\?ClientAliveInterval/c\ClientAliveInterval 36000' /etc/ssh/sshd_config
sed -i '/^#\?ClientAliveCountMax/c\ClientAliveCountMax 10' /etc/ssh/sshd_config
sed -i '/^#\?PermitTunnel/c\PermitTunnel yes' /etc/ssh/sshd_config

sed -i 's/^#*\s*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*\s*PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
sed -i 's/^#*\s*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config


useradd ${USER_REMOTE}
mkdir /home/${USER_REMOTE}
chown ${USER_REMOTE}:${USER_REMOTE} /home/${USER_REMOTE}
usermod -aG sudo ${USER_REMOTE}
sed -i "/$USER_REMOTE/s|/bin/sh|/bin/bash|" /etc/passwd

passwd ${USER_REMOTE}


sed -i 's/\\h/\\H/' ~/.bashrc
#sed -i 's/\\h/\\H/' /etc/bash.bashrc
source ~/.bashrc

#--------------------------------------------------
#копируем свой ключ
# ssh-copy-id USERNAME@имя сервера/адрес
#----
# не забудьте выполнить systemctl restart sshd
#--------------------------------------------------






