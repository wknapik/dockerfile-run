project_root := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# A recursive find function (https://gist.github.com/wknapik/94582e964321af704d30c25ccbbf7320).
find = $(foreach path,$1,$(foreach pattern,$2,$(wildcard $(path)/$(pattern)) $(foreach dir,$(wildcard $(path)/*/),$(call find,$(dir:%/=%),$(pattern)))))

tests := $(patsubst $(project_root)/%.sh,%,$(call find,$(project_root)/test,*.sh))

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
	cd "$(project_root)/$(dir $@)" && bash $(bash_opt) "./$(notdir $@).sh" </dev/null

shellcheck:
	find "$(project_root)" -type f \( -name dockerfile-run -o -name '*.sh' \) -print0|\
		xargs -0 -I{} shellcheck -s bash -e SC2096 "{}"
