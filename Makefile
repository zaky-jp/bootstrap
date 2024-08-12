include .config/make/default.mk
export PATH := $(abspath $(CURDIR)/.local/bin):$(PATH)


# run install when package.json is newer than package-lock.json
.PHONY: npm
npm: | package-lock.json;
package-lock.json: package.json
	npm install

.PHONY: bootstrap
bootstrap:
	$(MAKE) -C $(CURDIR)/bootstrap
