# @build
.PHONY: all test clean
INTERMEDIATE_FILES := formulae_list.txt docker.config.json # define intermediate files
## @all
all: $(INTERMEDIATE_FILES) .gitignore;
formulae_list.txt:
	$(LOG) INFO "Generating brewed formulae list."
	brew list --formulae -1 | tee $@ 1>/dev/null
docker.config.json: generate_config.sh
	$(LOG) INFO "Generating docker config."
	$(CURDIR)/generate_config.sh | tee $@ 1>/dev/null
.gitignore: $(lastword $(MAKEFILE_LIST)) # auto-generate .gitignore
	$(LOG) INFO "Generating .gitignore."
	@echo $(INTERMEDIATE_FILES) | xargs -n 1 > $@
## @end
test:
	$(LOG) WARN "Nothing to test."
clean:
	$(RM) $(INTERMEDIATE_FILES)
# @end

# @install
LIMA_VM := docker
.PHONY: install
install: install-formulae.lock docker-config lima-$(LIMA_VM).lock docker-context;

# install prerequisite brew formulae
FORMULAE_LIST := lima docker docker-buildx docker-compose docker-credential-helper
formula_status = $(shell cat formulae_list.txt | grep $(strip $1))
define install_formula
  $(if $(call formula_status, $1),
	$(LOG) DEBUG "$(strip $1) already installed.",
	brew install --formulae $(strip $1)
  )
endef
install-formulae.lock: | formulae_list.txt
	$(LOG) INFO "Installing formulae..."
	$(foreach f, $(FORMULAE_LIST), $(call install_formula, $f))
	touch $@

# install docker config
CONFIG_DEST := $(XDG_CONFIG_HOME)/docker/config.json
.PHONY: docker-config
docker-config: docker.config.json
	$(LOG) INFO "Copying and symlinking docker config."
	$(MKDIR) $(dir $(CONFIG_DEST))
	$(CP) -f $(CURDIR)/docker.config.json $(CONFIG_DEST)
	ln -sf $(CONFIG_DEST) $(HOME)/.docker/config.json

# install lima vm
get_lima_vm = $(shell limactl list -q $1 2>/dev/null)
lima-$(LIMA_VM).lock: | install-formulae.lock
	$(LOG) INFO "Creating lima vm..."
	$(if $(call get_lima_vm, $(LIMA_VM)),\
	$(LOG) DEBUG "$(LIMA_VM) already exist.",\
	limactl create --name=$(LIMA_VM) --tty=false template://docker; \
	limactl edit $(LIMA_VM) --mount-writable --tty=false)
	touch $@

# create docker context
DOCKER_CONTEXT := lima
DOCKER_SOCKET = $(shell limactl list $(LIMA_VM) --format 'unix://{{.Dir}}/sock/docker.sock')
get_docker_context = $(shell docker context ls -q | grep $(strip $1))
.PHONY: docker-context
docker-context: | lima-$(LIMA_VM).lock
	$(LOG) INFO "Creating docker context..."
	$(if $(call get_docker_context, $(DOCKER_CONTEXT)),\
	$(LOG) DEBUG "$(DOCKER_CONTEXT) already exist", \
	docker context create $(DOCKER_CONTEXT) --docker "host=$(DOCKER_SOCKET)")
# @end

# @check / @installcheck
.PHONY: check
check: ## start lima vm
	$(LOG) INFO "Starting lima vm."
	$(if $(call get_lima_vm, $(LIMA_VM)), \
	$(LOG) DEBUG "$(LIMA_VM) already running.", \
	limactl start $(LIMA_VM))
	$(LOG) INFO "Switching docker context."
	@ docker context use $(DOCKER_CONTEXT)
# @end
