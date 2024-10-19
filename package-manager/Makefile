define install-actions
	@ $(LOG) INFO "Configuring $(strip $1)..."
	@ $(MAKE) -C $(CURDIR)/$(strip $1)
	@ $(MAKE) -C $(CURDIR)/$(strip $1) test install
	@ $(MAKE) -C $(CURDIR)/$(strip $1) check
endef

.PHONY: brew
brew:
	$(call install-actions, brew)

.PHONY: apt
apt:
	$(call install-actions, apt)
