#!/bin/bash

##
# Define user and group credentials used by worker processes
##

group=$(grep ":$PGID:" /etc/group | cut -d: -f1)

if [[ -z "$group" ]]; then
	group='webdav'
	echo "Adding group $group($PGID)"
	addgroup --system --gid $PGID $group
fi

user=$(getent passwd $PUID | cut -d: -f1)

if [[ -z "$user" ]]; then
	user='webdav'
	echo "Adding user $user($PUID)"
	adduser --system --disabled-login --gid $PGID --no-create-home --home /nonexistent --gecos "webdav user" --shell /bin/false --uid $PUID $user
fi

echo "Credentials used by worker processes: user $user($PUID), group $group($PGID)."

##
# Update Nginx Config
##

sed -i 's/^user\s.*$/user '"$user $group"';/g' /etc/nginx/nginx.conf
sed -i 's/^pid\s.*$/pid \/tmp\/nginx.pid;/g' /etc/nginx/nginx.conf

##
# Setting Up Webdav Directory
##

chown $user:$group /opt/webdav
chown $user:$group /opt/config

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
# Run Nginx
##

nginx -g "daemon off;"
