# Created: Wed Dec 22 10:33:56 EST 2010
# Author: Vincent Batts, vbatts@hashbangbash.com

PKGNAM := slack-utils
TMP := /tmp
CWD = $(PWD)

build: .slackpkg .gem

.bundle: local.conf $(shell find src/ -type f)
	. local.conf && \
	rm -f $(PKGNAM)-$$VERSION-*.tar.gz && \
	sh bundle.sh && \
	touch $@

.slackpkg: .bundle
	. local.conf && \
	mkdir -p $(CWD)/pkg && \
	sudo OUTPUT=$(CWD)/pkg \
	VERSION=$$VERSION \
	TAG=$$TAG \
	BUILD=$$BUILD \
	sh $(PKGNAM).SlackBuild && \
	touch $@

.gem: 
	. local.conf && \
	mkdir -p $(CWD)/pkg && \
	cd src/ && \
	rake gem && \
	mv pkg/$(PKGNAM)-$$VERSION.gem ../pkg && \
	touch $@

reinstall: .slackpkg
	. local.conf && \
	sudo upgradepkg --reinstall --install-new $(CWD)/pkg/$(PKGNAM)-$$VERSION-$$ARCH-$$BUILD$$TAG.tgz

clean:
	. local.conf && \
	rm -f $(PKGNAM)-$$VERSION.tar.gz
