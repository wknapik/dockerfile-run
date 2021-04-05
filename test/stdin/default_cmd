#!/usr/bin/env -S bash -eEo pipefail

[[ "$(echo -e "FROM alpine\nCMD grep '^NAME' /etc/os-release"|dockerfile-run -)" == 'NAME="Alpine Linux"' ]]
