#!/bin/sh
#

# If command starts with an option, prepend minio.
if [ "${1}" != "console" ]; then
	if [ -n "${1}" ]; then
		set -- console "$@"
	fi
fi

docker_switch_user() {
	if [ -n "${CONSOLE_USERNAME}" ] && [ -n "${CONSOLE_GROUPNAME}" ]; then
		if [ -n "${CONSOLE_UID}" ] && [ -n "${CONSOLE_GID}" ]; then
			chroot --userspec=${CONSOLE_UID}:${CONSOLE_GID} / "$@"
		else
			echo "${CONSOLE_USERNAME}:x:1000:1000:${CONSOLE_USERNAME}:/:/sbin/nologin" >>/etc/passwd
			echo "${CONSOLE_GROUPNAME}:x:1000" >>/etc/group
			chroot --userspec=${CONSOLE_USERNAME}:${CONSOLE_GROUPNAME} / "$@"
		fi
	else
		exec "$@"
	fi
}

## DEPRECATED and unsupported - switch to user if applicable.
docker_switch_user "$@"
