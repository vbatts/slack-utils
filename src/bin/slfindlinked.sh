#!/bin/sh
# Copyright 2010,2011  Vincent Batts, Vienna, VA
# All rights reserved.
#
# Redistribution and use of this source, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this source must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
