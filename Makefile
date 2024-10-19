include .config/make/default.mk
export PATH := $(abspath $(CURDIR)/.local/bin):$(PATH)
export RUNOS ?= $(eval RUNOS := $(shell getos)) # set once if not already defined

# run install when package.json is newer than package-lock.json
.PHONY: npm
npm: | package-lock.json;
package-lock.json: package.json
	npm install

.PHONY: volta
volta: | volta.lock;
volta.lock:
	volta install npm

.PHONY: init
init:
	$(LOG) INFO "Bootstrapping $(RUNOS)"
	@ $(MAKE) package-manager

.PHONY: package-manager
package-manager:
ifeq "$(RUNOS)" "macos"
	@ $(MAKE) -C $(CURDIR)/package-manager brew
endif
ifeq "$(RUNOS)" "ubuntu"
	@ $(MAKE) -C $(CURDIR)/package-manager apt
endif
