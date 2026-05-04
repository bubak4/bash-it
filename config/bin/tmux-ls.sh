#!/bin/bash
# Time-stamp: <2026-04-28 23:46:44 martin>

session="LS"

declare -A TARGET_DIRS
TARGET_DIRS["op"]="$HOME/src/livesystems/openplatform/openplatform-orchestration"
TARGET_DIRS["op-AI"]="$HOME/src/livesystems/openplatform"
TARGET_DIRS["cy"]="$HOME/src/livesystems/cysensic/cysensic-orchestration"
TARGET_DIRS["cy-AI"]="$HOME/src/livesystems/cysensic"
TARGET_DIRS["spvs"]="$HOME/src/livesystems/spvs/openassets-orchestration"
TARGET_DIRS["lkp"]="$HOME/src/livesystems/lkp/lkp-orchestration"
TARGET_DIRS["oa"]="$HOME/src/livesystems/openassets/openassets-orchestration"
TARGET_DIRS["ppas"]="$HOME/src/livesystems/ppas/ppas-orchestration"

tmux new-session -d -s "$session"

for key in "${!TARGET_DIRS[@]}"; do
    printf "%s -> %s\n" "$key" "${TARGET_DIRS[$key]}"
    tmux new-window -n "$key" -t "$session" -c "${TARGET_DIRS[$key]}"
done

# attach main session with OpenPlatform shell preselected
tmux select-window -t "$session":1
tmux attach-session -t "$session"
