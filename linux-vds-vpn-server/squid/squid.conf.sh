#!/bin/bash
#Proxy setup  


DIR_PATH=$(dirname "$(realpath "$0")")
source "$DIR_PATH/variables.sh"




apt-get install  squid -y
apt-get install apache2-utils -y




#uncoment include if commented
sed -i 's/^#\(include \/etc\/squid\/conf.d\/\*\.conf\)/\1/' /etc/squid/squid.conf

#add auth digest
cat <<EOL > /etc/squid/conf.d/auth_digest.conf
auth_param digest program /usr/lib/squid/digest_file_auth -c /etc/squid/passwd_digest
auth_param digest children 5
auth_param digest credentialsttl 2 hours
auth_param digest casesensitive on
auth_param digest realm $REALM
acl auth_users proxy_auth REQUIRED
http_access allow auth_users
EOL



#create pass file
htdigest -c /etc/squid/passwd_digest $REALM  $USERNAME1

#then add some users:
#htdigest  /etc/squid/passwd_digest  $REALM username2


systemctl enable squid
systemctl start squid
