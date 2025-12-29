#!/bin/env bash

# $1 = file identifier
# $2 = notification type
function ytdla_send_notification() {
  local id
  local title="yt-dla"
  local content
  local priority="low"

  id=$(echo "$1" | md5sum | cut -c 1-10)

  case "$2" in
    "start")
      content="Downloading: $1"
      ;;
    "success")
      content="Successfully downloaded: $1"
      ;;
    "error")
      content="Error trying to download: $1"
      priority="high"
      ;;
    *)
      content="Unknown status: $2"
      ;;
  esac

  termux-notification \
    --id "$id" \
    --title "$title" \
    --content "$content" \
    --priority "$priority"
}

export -f ytdla_send_notification
