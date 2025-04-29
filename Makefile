#!/usr/bin/make
#
# go-taskのインストールまでを自動化するスクリプト
# 必要に応じてpackage-managerの設定も行う

# 初期化
export MAKEFILES := $(abspath $(CURDIR)/src/make/default.mk)
include $(MAKEFILES)
export RUNOS ?= $(eval RUNOS := $(shell ./.local/bin/getos)) # 下記PATH設定よりもshellコマンド実行の方が早いためgetosを相対パスにて指定
export PATH := $(abspath $(CURDIR)/.local/bin):$(PATH) # slogを利用するためにPATHに追加する

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
