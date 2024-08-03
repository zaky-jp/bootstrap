include .config/make/Makefile

package-lock.json: package.json
	npm install

.PHONY: cspell
cspell: | package-lock.json;

.PHONY: init
init:
	$(MAKE) -C src/docker start
