define install-actions
	@ $(LOG) INFO "Configuring docker on $(strip $1)..."
	@ $(MAKE) -f $(CURDIR)/$(strip $1).mk
	@ $(MAKE) -f $(CURDIR)/$(strip $1).mk test install
	@ $(MAKE) -f $(CURDIR)/$(strip $1).mk check
endef

.PHONY: all
all:
	$(call install-actions, $(RUNOS))
