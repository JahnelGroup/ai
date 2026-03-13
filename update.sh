#!/bin/bash

set -euo pipefail

PLATFORM="${1:-}"

if [[ -z "$PLATFORM" ]]; then
  echo "Error: You must specify a platform."
  echo "Usage: ./update.sh <cursor|claude>"
  exit 1
fi

# Pull latest changes
git pull origin main  # Assume main branch; adjust if needed

# Re-run install to refresh symlinks (in case structure changed)
./install.sh "$PLATFORM"

echo "Update complete for $PLATFORM!"