# prerequisites
REQUIRED_PACKAGES := lima docker docker-buildx docker-compose docker-credential-helper
# vm configs
LIMA_VM := docker
# docker configs
DOCKER_CONFIG := $(HOME)/.docker/config.json
DOCKER_SOCKET = $(shell limactl list $(LIMA_VM) --format 'unix://{{.Dir}}/sock/docker.sock')
DOCKER_CONTEXT := lima

# @define install actions
INSTALL_ACTIONS := install-prerequisites install-docker-config install-lima-vm install-docker-context
.PHONY: install $(INSTALL_ACTIONS)
install: $(INSTALL_ACTIONS);
# @end

# @define state files which inject and/or assume dependencies
LIMA_VM_STATE := lima-$(LIMA_VM).lock
DOCKER_CONTEXT_STATE := docker-context.lock

install-prerequisites: $(PREREQUISITE_STATE);
install-docker-config: $(DOCKER_CONFIG_STATE);
install-lima-vm: $(LIMA_VM_STATE);
install-docker-context: $(DOCKER_CONTEXT_STATE);
# @end

# @define actual actions per state file

$(PREREQUISITE_STATE): | $(STATES_DIR)
	@print_log INFO "Installing prerequisite packages..."
	brew install --formulae $(REQUIRED_PACKAGES)
	touch $@

vpath config.json $(XDG_CONFIG_HOME)/docker
config.json: | generate_config.sh
	$(MKDIR) $(XDG_CONFIG_HOME)/docker
	@print_log INFO "Generating docker config."
	$(CURDIR)/generate_config.sh | tee $@ 1>/dev/null

$(DOCKER_CONFIG_STATE): $(LOCAL_CONFIG)
	@print_log WARN "Will overwrite existing docker config."
	rm $(DOCKER_CONFIG)
	ln -s $(abspath $(LOCAL_CONFIG)) $(DOCKER_CONFIG)


$(LIMA_VM_STATE): | $(PREREQUISITE_STATE)
	@print_log INFO "Creating lima vm..."
	limactl create --name=$(LIMA_VM) --tty=false template://docker
	limactl edit $(LIMA_VM) --mount-writable --tty=false
	touch $@

$(DOCKER_CONTEXT_STATE): | $(LIMA_VM_STATE)
	@print_log INFO "Creating docker context..."
	docker context create $(DOCKER_CONTEXT) --docker "host=$(DOCKER_SOCKET)"
	touch $@
# @end

# @define other targets

.PHONY: start
start: | $(DOCKER_CONTEXT_STATE) ## start lima vm
	limactl start $(LIMA_VM)
	docker context use $(DOCKER_CONTEXT)

.PHONY: purge
purge: ## purge existing environment including vms
	limactl stop $(LIMA_VM) && limactl delete $(LIMA_VM) && rm $(LIMA_VM).lock
	docker context rm $(DOCKER_CONTEXT) && rm context.lock

.PHONY: uninstall
uninstall: | purge ## uninstall installed formulae, with preceding purge
	brew uninstall --formulae $(REQUIRED_PACKAGES)

.PHONY: clean
clean: ## clean platform dependent files
	@print_log WARN "Deleting existing docker config."
	[[ -f $(LOCAL_CONFIG) ]] && rm $(LOCAL_CONFIG) || true

.PHONY: all
all: | clean install start;
# @end
