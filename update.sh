#!/bin/bash

# Pull latest changes
git pull origin main  # Assume main branch; adjust if needed

# Re-run install to refresh symlinks (in case structure changed)
./install.sh

echo "Update complete!"