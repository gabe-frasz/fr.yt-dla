#!/bin/bash

url=$1
audio_output_dir="$HOME/storage/shared/Music"
video_output_dir="$HOME/storage/shared/Movies"
log_file="$HOME/yt-dlp.log"

if [ -z "$url" ]; then
  termux-toast "No URL provided!"
  exit 1
fi

if [ ! -f "$HOME/yt-dlp.log" ]; then
  touch "$HOME/yt-dlp.log"
fi

download_options=(
  "Audio - Best (M4A)"
  "Audio - Classic (MP3)"
  "Video - Highest (Max)"
  "Video - Balanced (720p)"
  "Video - Fast (360p)"
)

old_ifs=$IFS
IFS=,
options_str="${download_options[*]}"
IFS=$old_ifs

json_options_response=$(termux-dialog radio -t "Download as" -v "$options_str")
option_index=$(echo "$json_options_response" | jq -r ".index")
option=$(echo "$json_options_response" | jq -r ".text")

if [[ "$option_index" == "null" ]] || [[ $option_index -lt 0 ]] || [[ -z "$option" ]]; then
  termux-toast "Download cancelled"
  exit 0
fi

case $option_index in
  0) yt_dlp_args="-f ba[ext=m4a] --extract-audio" ;; # Audio M4A
  1) yt_dlp_args="-x --audio-format mp3 --audio-quality 0" ;; # Audio MP3
  2) yt_dlp_args="-f bv*+ba/b" ;; # Video Max
  3) yt_dlp_args="-f bestvideo[height<=720]+bestaudio/best[height<=720]" ;; # Video 720p
  4) yt_dlp_args="-f bestvideo[height<=360]+bestaudio/best[height<=360]" ;; # Video 360p
esac

if [[ $option_index -lt 2 ]]; then
  cd $audio_output_dir
else
  cd $video_output_dir
fi

(
  termux-wake-lock

  termux-notification --id 1 --title "yt-dla" --content "Downloading: $url"

  echo "####### Downloading: $url #######" >> $log_file

  # yt-dlp
  # --no-mtime: uses today date instead of video upload date
  # --restrict-filenames: remove special chars and spaces
  # -o: output template

  yt-dlp $yt_dlp_args \
  --no-mtime \
  --restrict-filenames \
  --exec "termux-media-scan {}" \
  -o "%(title)s.%(ext)s" \
  "$url" >> $log_file 2>&1

  if [ $? -eq 0 ]; then
    termux-notification --id 1 --title "yt-dla" --content "Successfully downloaded: $url"
  else
    termux-notification --id 1 --title "yt-dla" --content "Error trying to download: $url" --priority high
  fi

  termux-wake-unlock
) & disown

exit 0
