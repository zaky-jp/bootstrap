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
INSTALL := sudo install -b -S
LOG := @slog
APT := sudo apt-get
CP := cp -an
vpath *.lock $(XDG_RUNTIME_DIR)
# @end

# @define default targets
.DEFAULT_GOAL := all
# @end
