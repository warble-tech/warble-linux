#!/bin/bash
# Compatibility wrapper — prefer: make bake  or  ./scripts/make-and-bake.sh
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/make-and-bake.sh" "$@"
