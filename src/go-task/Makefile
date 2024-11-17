#!/usr/bin/make
#
# go-taskを自動インストールするスクリプト

# target定義
#
# 'all' target
.PHONY: all
all: install;

# flow targets
.PHONY: install
install:
	$(LOG) INFO "go-taskをインストールします..."
	$(MAKE) task

# runner targets
vpath task /snap/bin /usr/local/bin /opt/homebrew/bin
task:
ifeq "$(RUNOS)" "macos"
	brew install --formulae go-task
else ifeq "$(RUNOS)" "ubuntu"
	$(SNAP) install task --classic
else
	exit 1
endif
