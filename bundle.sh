#!/bin/sh

CWD=$(pwd)
TMP=${TMP:-/tmp}

if [ -r $CWD/local.conf ] ;then
	. $CWD/local.conf
else
	echo "ERROR: local.conf not found"
	exit 1
fi

rm -rf $TMP/${PRGNAM}-${VERSION}
cp -a $CWD/src $TMP/${PRGNAM}-${VERSION}
(cd $TMP && tar zcvf $CWD/${PRGNAM}-${VERSION}.tar.gz ${PRGNAM}-${VERSION})

