DIST_NAME := $(shell source /etc/os-release; echo $${VERSION_CODENAME})
ifeq "$(DIST_NAME)" 'noble'
APT_SOURCE := /etc/apt/sources.list.d/ubuntu.sources
APT_SOURCE_FILE := ubuntu.sources
else
APT_SOURCE := /etc/apt/sources.list
APT_SOURCE_FILE := sources.list
endif
MIRROR_FILE := /etc/apt/mirrors.txt

# @build
.PHONY: all test clean
all: $(APT_SOURCE_FILE);

$(APT_SOURCE_FILE): set-mirrors.pl
	$(LOG) INFO "Generating apt source file with mirrors."
	perl set-mirrors.pl $(APT_SOURCE) $(MIRROR_FILE) | tee $@ 1>/dev/null

test:
	$(LOG) WARN "Nothing to test."

clean:
	$(LOG) DEBUG "Removing intermediate files."
	$(RM) $(APT_SOURCE_FILE)
# @end

# @install
.PHONY: install
install: apt.mirrors.lock apt.conf.lock;

.PHONY: mirrors
mirrors: mirrors.txt.$(shell uname -i)
	$(INSTALL) -m 644 $< /etc/apt/mirrors.txt

.PHONY: config-mirrors
config-mirrors: $(APT_SOURCE_FILE)
	$(INSTALL) -b -m 644 $< $(APT_SOURCE)

apt.mirrors.lock:
	$(LOG) WARN "Adding apt mirrors. You need to manually undo this if you no longer need mirrors."
	@ $(MAKE) mirrors
	@ $(MAKE) config-mirrors
	touch $@

apt.conf.lock: default.conf
	$(LOG) WARN "Enable apt caching if you are in container"
	sudo $(RM) /etc/apt/apt.conf.d/docker-clean
	$(LOG) INFO "Adding default apt configuration."
	$(INSTALL) -m 644 $< /etc/apt/apt.conf.d/99apt.conf
	touch $@
# @end

# @check / @installcheck
.PHONY: check
check:
	$(LOG) INFO "Checking if apt repositories can be fetched..."
	@ $(APT) update
# @end
