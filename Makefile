# All paths start with the folder containing this Makefile.
project_root := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# All test targets (of the form `test/.../some_test').
tests := $(shell find "$(project_root)/test" -type f -executable -not \
    -iname '*.dockerfile' -not -iname 'Dockerfile*' -printf "test/%P\n")

# All test suite targets (each folder in the test/ tree).
test_suites := $(patsubst test/,test,$(shell \
    find "$(project_root)/test" -type d -printf "test/%P\n"))

# By default run tests and shellcheck.
all: test shellcheck

# Rebuild some targets unconditionally, be quiet and delete invalid files.
.PHONY: all shellcheck $(test_suites) $(test_suites:%=%/) $(tests)
$(VERBOSE).SILENT:
.DELETE_ON_ERROR:

# Use bash in recipes and fail fast.
SHELL := $(shell command -v bash)
SHELLFLAGS := -eEo pipefail -c

# If `VERBOSE=1' is passed, execute tests with `set -x'.
ifeq ($(VERBOSE),1)
    bash_opt := -x
endif

# Use `dockerfile-run' from this folder in tests.
$(tests): export PATH := $(PATH):$(project_root)

# Execute tests from their folders, detaching stdin from terminal.
$(tests):
	cd "$(project_root)/$(dir $@)" &&\
	DFR_VERBOSITY=0 bash $(bash_opt) "./$(notdir $@)" </dev/null

# Run `shellcheck' on all shell scripts.
shellcheck:
	find "$(project_root)" -type f \( -name dockerfile-run -o -name '*.sh' \) -print0|\
	    xargs -0 -I{} shellcheck -s bash -e SC2096 "{}"

# Generate test suite targets for every point in the test/ tree.
.SECONDEXPANSION:
$(test_suites): $$(filter $$@/%,$(tests))
$(test_suites:%=%/): $$(filter $$@%,$(tests))
