#!/bin/bash
#initial setup 

DIR_PATH=$(dirname "$(realpath "$0")")
source "$DIR_PATH/variables.sh"




apt-get update -y
apt-get upgrade -y
apt install net-tools -y
apt install iptables -y

apt remove ufw -y

iptables -F
iptables -t mangle -F
iptables -t nat -F
iptables -t raw -F
iptables -Z
iptables -X

iptables -A INPUT -i tun+ -j ACCEPT
# iptables -A INPUT -i ppp+ -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p icmp  -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
# iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
# iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 3128 -j ACCEPT #if you want proxy additional
# iptables -A INPUT -p gre -j ACCEPT
iptables -t nat -A POSTROUTING -o $INTERFACE -s 192.168.0.0/16 -j MASQUERADE

iptables -A FORWARD -i tun+ -o $INTERFACE -j ACCEPT
iptables -A FORWARD -i $INTERFACE -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT


iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

apt install iptables-persistent -y 
netfilter-persistent save

apt install mc -y
apt install git -y



#uncomment net.ipv4.ip_forward=1
sed -i '/^#.*net.ipv4.ip_forward=1/s/^#//' /etc/sysctl.conf

#disaeble ipv6 - DO NOT FOGET REBOOT - all services need to load without ipv6(to many messages in logs) 
sudo sed -i '$a\net.ipv6.conf.all.disable_ipv6 = 1' /etc/sysctl.conf
sudo sed -i '$a\net.ipv6.conf.default.disable_ipv6 = 1' /etc/sysctl.conf
sudo sed -i '$a\net.ipv6.conf.lo.disable_ipv6 = 1' /etc/sysctl.conf

sysctl -p


#Setting foe sshd
sed -i '/^#\?ClientAliveInterval/c\ClientAliveInterval 36000' /etc/ssh/sshd_config
sed -i '/^#\?ClientAliveCountMax/c\ClientAliveCountMax 10' /etc/ssh/sshd_config
sed -i '/^#\?PermitTunnel/c\PermitTunnel yes' /etc/ssh/sshd_config

sed -i 's/^#*\s*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*\s*PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
sed -i 's/^#*\s*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config


useradd ${USER_ADD}
mkdir /home/${USER_ADD}
chown ${USER_ADD}:${USER_ADD} /home/${USER_ADD}
usermod -aG sudo ${USER_ADD}
sed -i "/$USER_ADD/s|/bin/sh|/bin/bash|" /etc/passwd

passwd ${USER_ADD}

# fqdn hostname in console
sed -i 's/\\h/\\H/' ~/.bashrc
sed -i 's/\\h/\\H/' /etc/bash.bashrc
source ~/.bashrc

#--------------------------------------------------
#------------Console vpn vds server
#Change root password
#passwd root 
#
#--------------Switch to the console home router
#  If you want ssh access to vds-server with user account, you need ssh-keys
# ssh-keygen # if you have not ssh keys. Generate if you want with passphrase
# ssh-copy-id vpn-server-fqdn     
# 
# sudo -s # you need root session
# ssh-keygen # if you have not ssh keys. Generate without passphrase
# ssh-copy-id root@vpn-server-fqdn     
#
#--------------Switch to the console vpn vds server
# systemctl restart sshd
#--------------------------------------------------






