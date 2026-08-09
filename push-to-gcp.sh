#!/bin/bash
# Compatibility wrapper → scripts/push-to-gcp.sh
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/push-to-gcp.sh" "$@"
