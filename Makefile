project_root := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
tests := $(patsubst $(project_root)/%/,%,$(wildcard $(project_root)/test/*/))

all: test shellcheck

.PHONY: all shellcheck test $(tests)
$(VERBOSE).SILENT:
.DELETE_ON_ERROR:

SHELL := $(shell command -v bash)
SHELLFLAGS := -eEo pipefail -c

ifeq ($(VERBOSE),1)
    bash_opt := -x
endif

test: $(tests)
$(tests):
	cd "$(project_root)/$@" && DFR_OPTS="--rm --init" bash $(bash_opt) ./test.sh

shellcheck:
	find "$(project_root)" -type f \( -name dockerfile-run -o -name '*.sh' \) -print0|\
		xargs -0 -I{} shellcheck -s bash -e SC2096 "{}"
