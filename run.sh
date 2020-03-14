#!/bin/sh
CONFIGURED="/configured"
if [ ! -f $CONFIGURED ]; then
	touch $CONFIGURED
	echo Configurating
	echo Add user $UUID
	echo "user:x:$UUID:$UUID:user:/home/user:/bin/nologin" >> /etc/passwd
fi

KEYS="/home/user/.ssh/authorized_keys"
if [ -f $KEYS ]; then
	chown user $KEYS
	chmod 600 $KEYS
	exec /bin/dropbear -RFEa $1
else
	echo "authorized_keys not found"
	exit 1
fi
