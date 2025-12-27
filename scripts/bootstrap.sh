#!/bin/env bash

apt update
pkg install python ffmpeg termux-api
pip install yt-dlp

mkdir ~/bin
cp ~/fr.yt-dla/scripts/termux-url-opener.sh ~/bin/termux-url-opener
chmod +x ~/bin/termux-url-opener
