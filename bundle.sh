#!/bin/sh

CWD=$(pwd)
TMP=${TMP:-/tmp}

if [ -r $CWD/local.conf ] ;then
	. $CWD/local.conf
else
	echo "ERROR: local.conf not found"
	exit 1
fi

if [ "$(git status --short | grep '^??' | wc -l)" -gt 0 ] ; then
	echo "ERROR: you have untracked files to address!"
	git status --short -uall | grep '^??'
	exit 1
fi

rm -rf $TMP/${PRGNAM}-${VERSION}
mkdir -p $TMP/${PRGNAM}-${VERSION}
cd  src/
git ls-files | while read line ; do
	echo "$line" | cpio -dump $TMP/${PRGNAM}-${VERSION}
done
cd ..
(cd $TMP && tar zcvf $CWD/${PRGNAM}-${VERSION}.tar.gz ${PRGNAM}-${VERSION})

