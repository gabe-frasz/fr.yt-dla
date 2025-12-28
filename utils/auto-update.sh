#!/bin/env bash

cd "$HOME/fr.yt-dla" || exit 1
git pull -q

pip install -U yt-dlp spotdl --no-warn-script-location > /dev/null 2>&1

cp "$HOME/fr.yt-dla/setup/termux-url-opener.sh" "$HOME/bin/termux-url-opener"
chmod +x "$HOME/bin/termux-url-opener"
