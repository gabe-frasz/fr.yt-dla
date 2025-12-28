#!/bin/bash

# This script is used as the entry point for Termux
# It is called when the user shares a URL using the Termux app

main_script="$HOME/fr.yt-dla/main.sh"

if [ -f "$main_script" ]; then
    "$main_script" "$@"
else
    echo "Error: main.sh not found"
    exit 1
fi
