#!/usr/bin/make
#
# apt設定を更新するMakefile

# 変数定義
DIST_NAME := $(shell source /etc/os-release; echo $${VERSION_CODENAME})

# target定義
#
# 'all' target
.PHONY: all
all: install check;

# flow targets
.PHONY: install
install: enable-caching configure set-mirrors;

.PHONY: enable-caching
enable-caching:
	$(LOG) NOTICE "aptによるcachingを有効化します."
	$(MAKE) $(INSTALL_CACHING_LOCK)

.PHONY: configure
configure:
	$(LOG) NOTICE "aptの共通設定を投入します."
	$(MAKE) $(INSTALL_CONF_FILE)

.PHONY: set-mirrors
set-mirrors:
	$(LOG) INFO "architectureに応じてmirrors.txtをコピーします..."
	$(MAKE) $(INSTALL_MIRROR_FILE)
	$(LOG) INFO "security以外のレポジトリの参照先をmirrors.txtに変更します..."
	$(MAKE) $(INSTALL_SOURCE_LOCK)

.PHONY: check
check:
	$(LOG) INFO "リモートレポジトリの情報が更新できるか確認します..."
	@ $(APT) update

.PHONY: clean
clean:
	$(LOG) DEBUG "lockファイルを削除します..."
	$(RM) $(INSTALL_CACHING_LOCK) $(INSTALL_SOURCE_LOCK)

# runner targets
#
# CACHING_LOCK:
# 公式コンテナイメージに/var/apt/cacheなどを削除する設定が入っており、
# buildkitのcachingが効かなくなるため削除する.
INSTALL_CACHING_LOCK := caching.lock
vpath $(INSTALL_CACHING_LOCK) $(XDG_RUNTIME_DIR)
$(INSTALL_CACHING_LOCK):
	sudo $(RM) /etc/apt/apt.conf.d/docker-clean
	touch $(XDG_RUNTIME_DIR)/$@

# CONF_FILE:
# apt.confのデフォルト設定を配置する.
# 最後に読み込ませたいため、prefixに99を指定する.
# 読み込み順についての詳細: https://manpages.ubuntu.com/manpages/noble/en/man5/apt.conf.5.html
INSTALL_CONF_FILE := /etc/apt.conf.d/99default.conf
$(INSTALL_CONF_FILE): default.conf
	$(INSTALL) -m 644 $< $@

# MIRROR_FILE:
# Architectureに応じて、日本からのレイテンシーが低く、帯域が太いミラーリストを指定する.
ORIG_MIRROR_FILE := mirrors.txt.$(shell uname -i)
INSTALL_MIRROR_FILE := /etc/apt/mirrors.txt
$(INSTALL_MIRROR_FILE): $(ORIG_MIRROR_FILE)
	$(INSTALL) -m 644 $< $@

# SOURCE_FILE:
# securityについては公式ミラーを使いたい一方、それ以外はMIRROR_FILEを参照させる.
# focal以前・以後でsourceファイルのフォーマットの変更があるため、それらにも対応する.
# 中間ファイルは.gitignoreに登録し、マシン上で都度生成させる.
ifeq "$(DIST_NAME)" 'noble'
ORIG_SOURCE_FILE := /etc/apt/sources.list.d/ubuntu.sources
INTERMEDIATE_SOURCE_FILE := ubuntu.sources
else
ORIG_SOURCE_FILE := /etc/apt/sources.list
INTERMEDIATE_SOURCE_FILE := sources.list
endif
INSTALL_SOURCE_LOCK := sources.lock

.INTERMEDIATE $(INTERMEDIATE_SOURCE_FILE)
$(INTERMEDIATE_SOURCE_FILE): set-mirrors.pl
	$(LOG) INFO "Generating apt source file with mirrors."
	perl set-mirrors.pl $(ORIG_SOURCE_FILE) $(INSTALL_MIRROR_FILE) | tee $@ 1>/dev/null

vpath $(INSTALL_SOURCE_LOCK) $(XDG_RUNTIME_DIR)
$(INSTALL_SOURCE_LOCK): $(INTERMEDIATE_SOURCE_FILE)
	$(INSTALL) -m 644 $< $@
	touch $(XDG_RUNTIME_DIR)/$(INSTALL_SOURCE_LOCK)
