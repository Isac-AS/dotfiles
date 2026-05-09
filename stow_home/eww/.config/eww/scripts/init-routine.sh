#!/bin/bash
# ~/.config/eww/scripts/init-routine.sh

JSON_FILE="$HOME/.config/eww/routines.json"
DAY_OF_WEEK=$(date +%u)   # 1=Monday, 7=Sunday

# If the file doesn't exist, return empty
if [[ ! -f "$JSON_FILE" ]]; then
    echo '{}'
    exit 0
fi

# Find the first routine that matches today's day of week
jq --argjson dow "$DAY_OF_WEEK" '
  map(select(.DEFAULT-DAY-OF-WEEK | index($dow))) |
  first // .[0] // {}
' "$JSON_FILE"
