#!/bin/bash
# Time-stamp: <2026-05-04 15:50:20 martin>

session="LS"

# Indexed array of "name:path" entries (": " as delimiter).
# Using an indexed array instead of an associative array (map) because
# associative arrays don't preserve insertion order — the loop below
# iterates in the order declared here, which controls tmux window order.
ENTRIES=(
    "op:$HOME/src/livesystems/openplatform/openplatform-orchestration"
    "op-AI:$HOME/src/livesystems/openplatform"
    "cy:$HOME/src/livesystems/cysensic/cysensic-orchestration"
    "cy-AI:$HOME/src/livesystems/cysensic"
    "spvs:$HOME/src/livesystems/spvs/openassets-orchestration"
    "lkp:$HOME/src/livesystems/lkp/lkp-orchestration"
    "oa:$HOME/src/livesystems/openassets/openassets-orchestration"
    "ppas:$HOME/src/livesystems/ppas/ppas-orchestration"
)

tmux new-session -d -s "$session"

for entry in "${ENTRIES[@]}"; do
    key="${entry%%:*}"
    dir="${entry#*:}"
    printf "%s -> %s\n" "$key" "$dir"
    tmux new-window -n "$key" -t "$session" -c "$dir"
done

# attach main session with OpenPlatform shell preselected
tmux select-window -t "$session":1
tmux attach-session -t "$session"
