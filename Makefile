#!/usr/bin/make
#
# go-taskのインストールまでを自動化するスクリプト
# 必要に応じてpackage-managerの設定も行う

# 初期化
export MAKEFILES := $(abspath $(CURDIR)/make/default.mk)
include $(MAKEFILES)
export PATH := $(abspath $(CURDIR)/.local/bin):$(PATH)
export RUNOS ?= $(eval RUNOS := $(shell getos)) # set once if not already defined

# target定義
#
# 'all' target
.PHONY: all
all: package-manager;

# flow targets
.PHONY: package-manager
package-manager:
	$(LOG) INFO "Bootstrapping $(RUNOS)"
ifeq "$(RUNOS)" "macos"
	$(MAKE) -C $(CURDIR)/package-manager/brew
endif
ifeq "$(RUNOS)" "ubuntu"
	$(MAKE) -C $(CURDIR)/package-manager/apt
endif
