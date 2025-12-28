#!/bin/env bash

cd "$HOME/fr.yt-dla" || exit 1
git restore .
git pull -q

pip install -U yt-dlp --no-warn-script-location > /dev/null 2>&1

cp "$HOME/fr.yt-dla/setup/termux-url-opener.sh" "$HOME/bin/termux-url-opener"
chmod +x "$HOME/bin/termux-url-opener"
chmod +x "$HOME/fr.yt-dla/main.sh"
