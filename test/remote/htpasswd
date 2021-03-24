#!/usr/bin/env -S bash -eEo pipefail

url=https://raw.githubusercontent.com/jessfraz/dockerfiles/master/htpasswd/Dockerfile
# shellcheck disable=SC2016
dockerfile-run "$url" -nbB user password|grep -qx 'user:$2y$.\{56,56\}'
