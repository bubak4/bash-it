#!/bin/bash
# Time-stamp: <2026-05-20 06:07:25 martin>

session="LS"

# Indexed array of "name:path" entries (": " as delimiter).
# Using an indexed array instead of an associative array (map) because
# associative arrays don't preserve insertion order — the loop below
# iterates in the order declared here, which controls tmux window order.
ENTRIES=(
    "op:$HOME/src/livesystems/openplatform/openplatform-orchestration"
    "op-AI [A]:$HOME/src/livesystems/openplatform:claude"
    "op-AI [B]:$HOME/src/livesystems/openplatform:claude"
    "op-test:$HOME/src/livesystems/openplatform/openplatform-test-suite:source .venv/bin/activate"
    "cy:$HOME/src/livesystems/cysensic/cysensic-orchestration"
    "cy-AI:$HOME/src/livesystems/cysensic"
    "spvs:$HOME/src/livesystems/spvs/openassets-orchestration"
    "lkp:$HOME/src/livesystems/lkp/lkp-orchestration"
    "oa:$HOME/src/livesystems/openassets/openassets-orchestration"
    "ppas:$HOME/src/livesystems/ppas/ppas-orchestration"
)

tmux new-session -d -s "$session"

for entry in "${ENTRIES[@]}"; do
    IFS=':' read -r key dir cmd <<< "$entry"
    printf "%s -> %s%s\n" "$key" "$dir" "${cmd:+ [$cmd]}"
    tmux new-window -n "$key" -t "$session" -c "$dir"
    [[ -n "$cmd" ]] && tmux send-keys -t "$session":"$key" "$cmd" Enter
done

# attach main session with OpenPlatform shell preselected
tmux select-window -t "$session":1
tmux attach-session -t "$session"
