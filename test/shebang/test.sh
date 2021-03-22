#!/usr/bin/env -S bash -eEo pipefail

[[ "$(./Dockerfile)" == 'default CMD' ]]
[[ "$(./Dockerfile grep '^NAME' /etc/os-release)" == 'NAME="Alpine Linux"' ]]
