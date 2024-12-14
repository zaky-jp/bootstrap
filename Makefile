#!/usr/bin/make
#
# go-taskのインストールまでを自動化するスクリプト
# 必要に応じてpackage-managerの設定も行う

# 初期化
export MAKEFILES := $(abspath $(CURDIR)/src/make/default.mk)
include $(MAKEFILES)
export PATH := $(abspath $(CURDIR)/.local/bin):$(PATH)
export RUNOS ?= $(eval RUNOS := $(shell getos)) # set once if not already defined

# target定義
#
# 'all' target
.PHONY: all
all: package-manager go-task;

# flow targets
.PHONY: package-manager go-task
package-manager:
	$(LOG) INFO "$(RUNOS)向けの初期設定を行います."
ifeq "$(RUNOS)" "macos"
	$(MAKE) -C $(CURDIR)/src/package-manager/brew
else ifeq "$(RUNOS)" "ubuntu"
	$(MAKE) -C $(CURDIR)/src/package-manager/apt
else
	exit 1
endif

go-task:
	$(MAKE) -C $(CURDIR)/src/go-task
