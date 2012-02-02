#!/bin/sh

CWD=$(pwd)
TMP=${TMP:-/tmp}

function check_versions() {
	exp_vers=$1

	found_vers=$(grep -e '^[[:space:]]*s.version' src/Rakefile | awk '{ print $3 }' | tr -d '"' | tr -d "'")
	if [ "$exp_vers" != "$found_vers" ] ; then
		echo "ERROR: src/Rakefile version ($found_vers) does not match $exp_vers"
		exit 1
	fi

	found_vers=$(grep -e '^[[:space:]]*UTILS_VERSION' src/lib/slackware/version.rb | awk '{ print $3 }' | tr -d '"' | tr -d "'")
	if [ "$exp_vers" != "$found_vers" ] ; then
		echo "ERROR: src/lib/slackware/version.rb version ($found_vers) does not match $exp_vers"
		exit 1
	fi
}

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

check_versions $VERSION

rm -rf $TMP/${PRGNAM}-${VERSION}
mkdir -p $TMP/${PRGNAM}-${VERSION}
cd  src/
git ls-files | while read line ; do
	echo "$line" | cpio -dump $TMP/${PRGNAM}-${VERSION}
done
cd ..
(cd $TMP && tar zcvf $CWD/${PRGNAM}-${VERSION}.tar.gz ${PRGNAM}-${VERSION})

