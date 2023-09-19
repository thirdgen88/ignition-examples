#!/usr/bin/env bash
set -euo pipefail

# Kick off the built-in entrypoint, with an in-built restore (-r <gwbk path>) directive
exec docker-entrypoint.sh -r base.gwbk "$@"
