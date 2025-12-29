#!/bin/env bash

# $1: video url
function get_video_title() {
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
