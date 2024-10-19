export RUNOS ?= $(eval RUNOS := $(shell getos)) # set once if not already defined

.PHONY: all
all:
	$(LOG) INFO "Bootstrapping $(RUNOS)"
	@ $(MAKE) package-manager
	@ $(MAKE) docker

.PHONY: package-manager
package-manager:
ifeq "$(RUNOS)" "macos"
	@ $(MAKE) -C $(CURDIR)/package-manager brew
endif
ifeq "$(RUNOS)" "ubuntu"
	@ $(MAKE) -C $(CURDIR)/package-manager apt
endif

.PHONY: docker
docker:
	@ $(MAKE) -C $(CURDIR)/docker
