#!/bin/sh

if [ -z $1 ] ; then
	echo ERROR: please specify a lib name to check for
	exit 1
fi

find /lib /lib64 /usr/lib /usr/lib64 /bin /sbin /usr/bin /usr/sbin -type f | \
	xargs file | \
	grep -E 'ELF.*(executable|shared object)' | \
	cut -d : -f 1 | \
	while read line ; do
		if ldd $line 2>&1 | grep -q $1 ; then
			echo "$(slf $(echo ${line} | sed -e 's|^/||')) linked to $(ldd $line 2>&1 | grep $1 | awk '{ print $1 }' | tr '\n' ' ' )"
		fi
	done
