#!/bin/env bash

# This script is used to first install the dependencies and configure the yt-dla

pkg update -y
pkg install -y git termux-api python ffmpeg jq
pip install yt-dlp

termux-setup-storage

mkdir -p "$HOME/bin"
mkdir -p "$HOME/.tmp"
mkdir -p "$HOME/storage/shared/Music"
mkdir -p "$HOME/storage/shared/Movies"

target_dir="$HOME/fr.yt-dla"

if [ -d "$target_dir" ]; then
  rm -rf "$target_dir"
fi

git clone https://github.com/gabe-frasz/fr.yt-dla.git "$target_dir"

cp "$HOME/fr.yt-dla/setup/termux-url-opener.sh" "$HOME/bin/termux-url-opener"
chmod +x "$HOME/bin/termux-url-opener"
