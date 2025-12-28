#!/bin/env bash

export base_dir="$HOME/fr.yt-dla"
export log_file="$HOME/yt-dlp.log"
export audio_output_dir="$HOME/storage/shared/Music"
export video_output_dir="$HOME/storage/shared/Movies"

# format: option label | downloader name | downloader arguments | directory type
download_options=(
  "Music - Classic MP3|spotdl|--output \"{title}.{ext}\"|AUDIO"
  "Audio - Modern M4A|yt-dlp|-f ba[ext=m4a] --extract-audio|AUDIO"
  "Video - Highest (Max)|yt-dlp|-f bv*+ba/b|VIDEO"
  "Video - Balanced (720p)|yt-dlp|-f bestvideo[height<=720]+bestaudio/best[height<=720]|VIDEO"
  "Video - Fast (360p)|yt-dlp|-f bestvideo[height<=360]+bestaudio/best[height<=360]|VIDEO"
)

function get_options_str() {
  local options_str=""

  for entry in "${download_options[@]}"; do
    local label="${entry%%|*}"

    if [ -z "$options_str" ]; then
      options_str="$label"
    else
      options_str="$options_str,$label"
    fi
  done

  return "$options_str"
}

function get_downloader_name_from_option() {
  local index=$1
  local chosen_option="${download_options[$index]}"

  return "$(echo "$chosen_option" | cut -d'|' -f2)"
}

function get_yt_dlp_args_from_option() {
  local index=$1
  local chosen_option="${download_options[$index]}"

  return "$(echo "$chosen_option" | cut -d'|' -f3)"
}

function get_dir_type_from_option() {
  local index=$1
  local chosen_option="${download_options[$index]}"

  return "$(echo "$chosen_option" | cut -d'|' -f4)"
}
