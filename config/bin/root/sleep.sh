#!/bin/bash
# see also pm/sleep.d/99_wifi

function comment_line() {
  local text="$1"
  echo ">> $text <<"
}

comment_line "close the lid in 2 seconds"
sleep 2 && systemctl suspend
