#!/usr/bin/env -S bash -eEo pipefail

[[ "$(echo FROM alpine|dockerfile-run - grep '^NAME' /etc/os-release)" == 'NAME="Alpine Linux"' ]]
