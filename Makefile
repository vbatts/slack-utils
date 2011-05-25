# Created: Wed Dec 22 10:33:56 EST 2010
# Author: Vincent Batts, vbatts@hashbangbash.com

PKGNAM := slack-utils
TMP := /tmp
CWD = $(PWD)

build: .slackpkg

bundle: local.conf $(wildcard src/* src/bin/* src/lib/**/*)
	. local.conf && \
	rm -f $(PKGNAM)-$$VERSION-*.tar.gz && \
	find . -type f -name '*~' -exec rm -f {} \; && \
	sh bundle.sh

slackpkg: bundle
	. local.conf && \
	mkdir -p $(CWD)/pkg && \
	sudo OUTPUT=$(CWD)/pkg \
	VERSION=$$VERSION \
	TAG=$$TAG \
	BUILD=$$BUILD \
	sh $(PKGNAM).SlackBuild

irb:
	irb -I$(CWD)/src/lib/ -r slackware

gem: 
	. local.conf && \
	mkdir -p $(CWD)/pkg && \
	cd src/ && \
	rake gem && \
	mv pkg/$(PKGNAM)-$$VERSION.gem ../pkg && \
	rm -rf pkg/

reinstall: slackpkg
	. local.conf && \
	sudo upgradepkg --reinstall --install-new $(CWD)/pkg/$(PKGNAM)-$$VERSION-$$ARCH-$$BUILD$$TAG.tgz

clean:
	. local.conf && \
	rm -f $(PKGNAM)-$$VERSION.tar.gz
