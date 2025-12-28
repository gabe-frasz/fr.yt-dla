#!/bin/env bash

export base_dir="$HOME/fr.yt-dla"
export log_file="$HOME/yt-dlp.log"
export audio_output_dir="$HOME/storage/shared/Music"
export video_output_dir="$HOME/storage/shared/Movies"

# format: option label | downloader name | downloader arguments | directory type
download_options=(
  "Audio - Classic MP3|yt-dlp|-x --audio-format mp3 --audio-quality 0 --add-metadata --embed-thumbnail|AUDIO"
  "Audio - Modern M4A|yt-dlp|-f ba[ext=m4a] --extract-audio --add-metadata --embed-thumbnail|AUDIO"
  "Video - Highest (Max)|yt-dlp|-f bv*+ba/b|VIDEO"
  "Video - Balanced (720p)|yt-dlp|-f bestvideo[height<=720]+bestaudio/best[height<=720]|VIDEO"
  "Video - Fast (360p)|yt-dlp|-f bestvideo[height<=360]+bestaudio/best[height<=360]|VIDEO"
)

for entry in "${download_options[@]}"; do
  label="${entry%%|*}"

  if [ -z "$options_str" ]; then
    options_str="$label"
  else
    options_str="$options_str,$label"
  fi
done

export download_options_str="$options_str"

function get_downloader_name_from_option() {
  local index=$1
  local chosen_option="${download_options[$index]}"

  echo "$chosen_option" | cut -d'|' -f2
}

function get_downloader_args_from_option() {
  local index=$1
  local chosen_option="${download_options[$index]}"

  echo "$chosen_option" | cut -d'|' -f3
}

function get_dir_type_from_option() {
  local index=$1
  local chosen_option="${download_options[$index]}"

  echo "$chosen_option" | cut -d'|' -f4
}
