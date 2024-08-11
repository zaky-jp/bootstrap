# @build
.PHONY: all test clean
all:
	$(LOG) WARN "Nothing to build or compile."
test:
	$(LOG) WARN "Nothing to test."
clean:
	$(LOG) WARN "Nothing to clean."
# @end

# @install
.PHONY: install
install: brew;

.INTERMEDIATE: install.sh
install.sh:
	$(LOG) DEBUG "Downloading Homebrew installer script."
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o $@

vpath brew /opt/homebrew/bin /usr/local/bin
brew: | install.sh
	$(LOG) INFO "Installing Homebrew..."
	bash -x $<
# @end

# @check / installcheck
.PHONY: check
check:
	$(LOG) INFO "Performing post-installation checks..."
	@brew doctor
# @end
