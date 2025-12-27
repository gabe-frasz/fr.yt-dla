#!/bin/bash

url=$1
audio_output_dir="~/storage/shared/Music"
video_output_dir="~/storage/shared/Movies"

if [ -z "$url" ]; then
    termux-toast "No URL provided!"
    exit 1
fi

download_options=(
  "Audio - Best (M4A)"
  "Audio - Classic (MP3)"
  "Video - Highest (Max)"
  "Video - Balanced (720p)"
  "Video - Fast (360p)"
)

json_options_response=(termux-dialog radio -t "Download as" -v "download_options[@]")
option_index=$(echo "$json_options_response" | jq ".index")
option=$(echo "$json_options_response" | jq -r ".text")

if [ "$option_index" == "-1" ]; then
    termux-toast "Download cancelled"
    exit 0
fi

case $option_index in
    0) ARGS="-f ba[ext=m4a] --extract-audio" ;; # Audio M4A
    1) ARGS="-x --audio-format mp3 --audio-quality 0" ;; # Audio MP3
    2) ARGS="-f bv*+ba/b" ;; # Max
    3) ARGS="-f bestvideo[height<=720]+bestaudio/best[height<=720]" ;; # 720p
    4) ARGS="-f bestvideo[height<=360]+bestaudio/best[height<=360]" ;; # 480p
esac

mkdir -p "$audio_output_dir"
mkdir -p "$video_output_dir"

if [ $option_index < 3 ]; then
    cd "$audio_output_dir"
else
    cd "$video_output_dir"
fi

termux-notification --id 1 --title "yt-dlp" --content "Downloading: $url"

# yt-dlp
# --no-mtime: uses today date instead of video upload date
# --restrict-filenames: remove special chars and spaces
# -o: output template

yt-dlp $ARGS \
--no-mtime \
--restrict-filenames \
-o "%(title)s [%(id)s].%(ext)s" \
"$URL"

if [ $? -eq 0 ]; then
    termux-notification --id 1 --title "yt-dlp" --content "Successfully downloaded: $url"
else
    termux-notification --id 1 --title "yt-dlp" --content "Error trying to download: $url" --priority high
fi
