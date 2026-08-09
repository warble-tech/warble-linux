#!/bin/bash
# Deprecated: use `make bake` or `./scripts/make-and-bake.sh`
echo "build.sh is deprecated. Use: make bake EDITION=4" >&2
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/make-and-bake.sh" "$@"
