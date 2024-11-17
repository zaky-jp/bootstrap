#!/usr/bin/make
#
# HomebrewをインストールするMakefile

# target定義
#
# 'all' target
.PHONY: all
all: install check;

# flow targets
.PHONY: install
install:
	$(LOG) INFO "Homebrewをインストールします..."
	$(MAKE) brew

.PHONY: check
check:
	$(LOG) INFO "Homebrewが正常にインストールされたかを確認します..."
	$(MAKE) $(CHECK_BREW_LOCK)

.PHONY: clean
clean:
	$(LOG) INFO "lockファイルを削除します..."
	$(RM) $(XDG_RUNTIME_DIR)/$(CHECK_BREW_LOCK)

# runner targets
vpath brew /opt/homebrew/bin /usr/local/bin
brew: | install.sh
	bash -x $<

.INTERMEDIATE: install.sh
install.sh:
	$(LOG) DEBUG "Homebrew installer scriptをダウンロードします."
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o $@

# CHECK_BREW_LOCK
# brew doctorが正常実行された場合はlockファイルを生成する.
# brewのversionごとに作成する.
CHECK_BREW_LOCK := $(shell printf 'brew_%s.lock' $$(brew --version | cut -w -f 2))
vpath $(CHECK_BREW_LOCK) $(XDG_RUNTIME_DIR)
$(CHECK_BREW_LOCK):
	@brew doctor
	@touch $(XDG_RUNTIME_DIR)/$@
