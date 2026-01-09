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
[[ -d "$target_dir" ]] && rm -rf "$target_dir"

start_script="$HOME/bin/termux-url-opener"
[[ -f "$start_script" ]] && rm "$start_script"

git clone https://github.com/gabe-frasz/fr.yt-dla.git "$target_dir"

cp "$target_dir/termux-url-opener.sh" "$start_script"
chmod +x "$start_script"
