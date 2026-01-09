#!/bin/env bash

# This script is meant to be run inside a termux environment

url=$1
[[ -z "$url" ]] && { termux-toast "No URL provided!"; exit 1; }

repo_dir="$HOME/fr.yt-dla"
tmp_repo_dir="$HOME/.tmp/fr.yt-dla"
log_file="$HOME/yt-dlp.log"
audio_output_dir="$HOME/storage/shared/Music"
video_output_dir="$HOME/storage/shared/Movies"

# format: option label | downloader name | downloader arguments | directory type
download_options=(
  "Audio - Classic MP3|yt-dlp|-x --audio-format mp3 --audio-quality 0 --add-metadata --embed-thumbnail|AUDIO"
  "Audio - Modern M4A|yt-dlp|-f ba[ext=m4a] --extract-audio --add-metadata --embed-thumbnail|AUDIO"
  "Video - Highest (Max)|yt-dlp|-f bv*+ba/b|VIDEO"
  "Video - Balanced (720p)|yt-dlp|-f bestvideo[height<=720]+bestaudio/best[height<=720]|VIDEO"
  "Video - Fast (360p)|yt-dlp|-f bestvideo[height<=360]+bestaudio/best[height<=360]|VIDEO"
)

# format above list into a string delimited by commas
download_options_str=""
for entry in "${download_options[@]}"; do
  label="${entry%%|*}"

  if [[ -z "$download_options_str" ]]; then
    download_options_str="$label"
  else
    download_options_str+=",$label"
  fi
done

ytdla_get_video_title() {
  local url="$1"
  local video_title
  local safe_title

  video_title=$(yt-dlp --print title --skip-download --socket-timeout 5 "$url" 2>/dev/null)
  if [ -z "$video_title" ]; then
    echo "$url"
    return 0
  fi

  safe_title=$(echo "$video_title" | tr -d '"`' | cut -c 1-50)
  if [ ${#video_title} -gt 50 ]; then safe_title="${safe_title}..."; fi

  echo "$safe_title"
}

ytdla_send_notification() {
  local file_id="$1"
  local notification_type="$2"

  local id content
  local title="yt-dla"
  local priority="low"

  id=$(echo "$file_id" | md5sum | cut -c 1-10)

  case "$notification_type" in
    "start")
      content="Downloading: $file_id"
      ;;
    "success")
      content="Successfully downloaded: $file_id"
      ;;
    "error")
      content="Error trying to download: $file_id"
      priority="high"
      ;;
    *)
      content="Unknown status: $notification_type"
      ;;
  esac

  termux-notification \
    --id "$id" \
    --title "$title" \
    --content "$content" \
    --priority "$priority"
}

ytdla_auto_update() {
  git clone https://github.com/gabe-frasz/fr.yt-dla.git "$tmp_repo_dir"

  pip install -U yt-dlp --no-warn-script-location > /dev/null 2>&1

  chmod +x "$tmp_repo_dir/termux-url-opener.sh"
  chmod +x "$tmp_repo_dir/main.sh"

  mv "$tmp_repo_dir/termux-url-opener.sh" "$HOME/bin/termux-url-opener"
  mv "$tmp_repo_dir/main.sh" "$repo_dir/main.sh"

  rm -rf "$tmp_repo_dir"
}

# main
json_options_response=$(termux-dialog radio -t "Download as" -v "$download_options_str")
option_index=$(echo "$json_options_response" | jq -r ".index")
chosen_option="${download_options[$option_index]}"
downloader_args=$(echo "$chosen_option" | cut -d'|' -f3)
dir_type=$(echo "$chosen_option" | cut -d'|' -f4)

if [[ "$option_index" == "null" || $option_index -lt 0 ]]; then
  termux-toast "Download cancelled"
  exit 0
fi

if [[ "$dir_type" == "AUDIO" ]]; then
  cd "$audio_output_dir" || exit 1
else
  cd "$video_output_dir" || exit 1
fi

(
  termux-wake-lock

  video_title=$(ytdla_get_video_title "$url")

  ytdla_send_notification "$video_title" "start"
  echo "[$(date)] START: $video_title ($dir_type)" >> "$log_file"

  # --no-mtime: use today date instead of video upload date
  # --restrict-filenames: remove special chars and spaces
  # -o: output template
  yt-dlp $downloader_args \
    --no-mtime \
    --restrict-filenames \
    --exec "termux-media-scan {}" \
    -o "%(title)s.%(ext)s" \
    "$url" >> "$log_file" 2>&1

  status=$?
  if [ $status -eq 0 ]; then
    ytdla_send_notification "$video_title" "success"
  else
    ytdla_send_notification "$video_title" "error"
  fi

  ytdla_auto_update >> "$log_file" 2>&1

  echo "[$(date)] END: $url ($dir_type)" >> "$log_file"

  termux-wake-unlock
) & disown

exit 0
