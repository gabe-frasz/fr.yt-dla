#!/bin/env bash

# $1 = file_identifier
# $2 = notification_type
function ytdla_send_notification() {
  local id=1
  local title="yt-dla"
  local content=""
  local priority="low"

  case "$2" in
    "start")
      content="Downloading: $1"
      ;;
    "success")
      content="Successfully downloaded: $1"
      ;;
    "error")
      content="Error trying to download: $1"
      priority="high" # Só vibra/toca se der erro
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
