#!/bin/env bash

# This script is meant to be run inside a termux environment

source "$HOME/fr.yt-dla/utils/config.sh"
source "$HOME/fr.yt-dla/utils/send-notification.sh"

url=$1

if [ -z "$url" ]; then
  termux-toast "No URL provided!"
  exit 1
fi

json_options_response=$(termux-dialog radio -t "Download as" -v "$download_options_str")
option_index=$(echo "$json_options_response" | jq -r ".index")

if [[ "$option_index" == "null" ]] || [[ $option_index -lt 0 ]]; then
  termux-toast "Download cancelled"
  exit 0
fi

dir_type=$(get_dir_type_from_option "$option_index")

if [[ "$dir_type" == "AUDIO" ]]; then
  cd "$audio_output_dir" || exit 1
else
  cd "$video_output_dir" || exit 1
fi

(
  termux-wake-lock
  send_notification "$url" "start"

  echo "[$(date)] START: $url ($dir_type)" >> "$log_file"

  downloader_name=$(get_downloader_name_from_option "$option_index")
  downloader_args=$(get_downloader_args_from_option "$option_index")

  case "$downloader_name" in
    "spotdl")
      spotdl "$url" $downloader_args >> "$log_file" 2>&1
      ;;
    "yt-dlp")
      # --no-mtime: use today date instead of video upload date
      # --restrict-filenames: remove special chars and spaces
      # -o: output template
      yt-dlp $downloader_args \
        --no-mtime \
        --restrict-filenames \
        --exec "termux-media-scan {}" \
        -o "%(title)s.%(ext)s" \
        "$url" >> "$log_file" 2>&1
      ;;
    *)
      echo "[$(date)] Unknown downloader: $downloader_name. Exiting..." >> "$log_file"
      send_notification "$url" "error"
      exit 1
      ;;
  esac

  status=$?
  if [ $status -eq 0 ]; then
    send_notification "$url" "success"
  else
    send_notification "$url" "error"
  fi

  bash "$HOME/fr.yt-dla/utils/auto-update.sh" >> "$log_file" 2>&1

  echo "[$(date)] END: $url ($dir_type)" >> "$log_file"

  termux-wake-unlock
) & disown

exit 0
