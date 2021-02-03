#!/bin/bash

if [ ! -e /usr/certs/cert.key ]; then
    echo ">>> Create certificate for TLS"
  	openssl req -x509 -nodes -days 36500 -newkey rsa:2048 -subj "/C=US/ST=Docker/L=Docker/O=httpd/CN=*" -keyout /usr/certs/cert.key -out /usr/certs/cert.crt;
	chmod 644 /usr/certs/cert.key;
	chmod 644 /usr/certs/cert.crt;
	echo "<<< Done"
fi

echo ">>> Create users"
for name in $USERS; do
	p=PASSWD_$name
	# Create home dir and update vsftpd user db:
	echo "--- Create user ${name} in /home/vsftpd/${name}"
	mkdir -p "/home/vsftpd/${name}"
	echo -e "${name}\n${!p}" >> /etc/vsftpd/virtual_users.txt
done

chown -R ftp:ftp /home/vsftpd/
/usr/bin/db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db
echo "<<< Done"

echo ">>> Create configuration"
# Set passive mode parameters:
if [ "$PASV_ADDRESS" = "**IPv4**" ]; then
    export PASV_ADDRESS=$(/sbin/ip route|awk '/default/ { print $3 }')
fi

/usr/sbin/substitute.py /etc/vsftpd/vsftpd.conf.tmp /etc/vsftpd/vsftpd.conf
echo "<<< Done"

echo ">>> Start server"
# stdout server info:

touch /var/log/vsftpd.log

# Run vsftpd:
/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
sleep 1
echo "<<< Done"

echo "---- Log file"
function byebye {
    echo "*** Shutdown"
	kill $(ps -x|grep /usr/sbin/vsftpd|grep -v grep|cut -d ' ' -f -4)
	exit 0
}
trap 'byebye' SIGTERM
tail -f /var/log/vsftpd.log & wait ${!}
