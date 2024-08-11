MAKEFILES ?= $(XDG_CONFIG_HOME)/make/default.mk

# @define sensible default
ifdef COMSPEC # only defined on Windows
  SHELL := pwsh
else
  SHELL := bash
  .SHELLFLAGS := -euo pipefail -c
endif
RM := rm -rf
MKDIR := mkdir -p
INSTALL := sudo install
LOG := @slog
APT := sudo apt-get
vpath *.lock $(XDG_RUNTIME_DIR)
# @end

# @define default targets
.DEFAULT_GOAL := all
.PHONY: help
help: ## Display this help
	@grep -E -h '^\S+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
# @end
