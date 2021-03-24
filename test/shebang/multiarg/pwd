#!/usr/bin/env -S bash -eEo pipefail

[[ "$(./Dockerfile pwd)" == /tmp ]]
[[ "$(dockerfile-run ./Dockerfile --dfr "-w /tmp" pwd)" == /tmp ]]
