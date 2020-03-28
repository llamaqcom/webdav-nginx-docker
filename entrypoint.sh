#!/bin/bash

##
# Webdav user preparation
##

user=$(getent passwd ${PUID} | cut -d: -f1)

if [[ -z "$user" ]]
then
	user='webdav'
	if ! grep -q ":${PUID}:" /etc/group; then
		echo "Adding group $user(${PUID})"
		addgroup --system --gid ${PUID} $user
	fi
	echo "Adding user $user(${PUID})"
	adduser --system --disabled-login --gid ${PUID} --no-create-home --home /nonexistent --gecos "webdav user" --shell /bin/false --uid ${PUID} $user
fi

id $user

group=$(grep ":${PUID}:" /etc/group | cut -d: -f1)
if [[ $user != $group ]]; then
	echo "Error! User '$user' and group '$group' do not match for id ${PUID}."
	exit 1
fi

##
# Setting Up Webdav Directory
##

chown $user: /opt/webdav
chown $user: /opt/config

##
# Webdav authentification
##

if [[ -f /opt/config/htpasswd ]]; then
	echo 'HTTP Basic Auth: using pre-existing htpasswd file'
	cp /opt/config/htpasswd /etc/nginx/htpasswd
elif [[ -n "$HT_USER" ]] && [[ -n "$HT_PASS" ]]; then
	echo 'HTTP Basic Auth: htpasswd file created'
	htpasswd -bc /etc/nginx/htpasswd $HT_USER $HT_PASS
else
	echo 'HTTP Basic Auth: disabled'
	sed -i '/auth_basic/d' /etc/nginx/conf.d/default.conf
fi

##
# Nginx
##

sed -i 's/^user\s.*$/user '"$user"';/g' /etc/nginx/nginx.conf
sed -i 's/^pid\s.*$/pid \/tmp\/nginx.pid;/g' /etc/nginx/nginx.conf

nginx -g "daemon off;"
