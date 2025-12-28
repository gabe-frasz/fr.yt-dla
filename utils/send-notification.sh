#!/bin/env bash

# $1 = file_identifier
# $2 = notification_type
function send_notification() {
  local id=1
  local title="yt-dla"

  case "$2" in
    "start")
      termux-notification --id $id --t $title -c"Downloading: $1"
      ;;
    "success")
      termux-notification --id $id --t $title -c"Successfully downloaded: $1"
      ;;
    "error")
      termux-notification --id $id --t $title -c"Error trying to download: $1" --priority high
      ;;
    *)
      echo "Unknown notification type: $2"
      ;;
  esac
}
