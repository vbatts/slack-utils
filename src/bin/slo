#!/bin/sh
# Fri Jul 16 16:11:04 EDT 2010
# written by vbatts@hashbangbash.com

## XXX this is way quick and dirty. there are several conditions that it doesn't account for

lines=$(egrep -e '\.new$' /var/log/removed_packages/*)
files=$(echo $lines | cut -d : -f 1 | sort -u)

echo $files | \
	while read line ; do \
		file=$line
		pkgs=$(echo ${lines} | grep "$line" | cut -d : -f 1 | xargs basename)
		if grep -q ${file} /var/log/packages/* ; then 
			continue
		fi
		if [ -e /${file/.new/} ] ;then
			echo "${file/.new/} orphaned by ${pkgs}"
		fi
	done
