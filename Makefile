project_root := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

tests := $(shell find "$(project_root)/test" -type f -executable -not \
	-iname '*.dockerfile' -not -iname Dockerfile -printf "test/%P\n")

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
$(tests): export PATH := $(PATH):$(project_root)
$(tests):
	cd "$(project_root)/$(dir $@)" && DFR_VERBOSITY=0 bash $(bash_opt) "./$(notdir $@)" </dev/null

shellcheck:
	find "$(project_root)" -type f \( -name dockerfile-run -o -name '*.sh' \) -print0|\
		xargs -0 -I{} shellcheck -s bash -e SC2096 "{}"
