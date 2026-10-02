#!/bin/bash
# Time-stamp: <2026-10-02 12:31:15 martin>

session="LS"

# Indexed array of "name:path" entries (": " as delimiter).
# Using an indexed array instead of an associative array (map) because
# associative arrays don't preserve insertion order — the loop below
# iterates in the order declared here, which controls tmux window order.
ENTRIES=(
    "op:$HOME/src/livesystems/openplatform/openplatform-orchestration/docker"
    "op-ai:$HOME/src/livesystems/openplatform:claude"
    "op2-ai:$HOME/src/livesystems/openplatform-2:claude"
    "op2:$HOME/src/livesystems/openplatform-2/openplatform-orchestration/docker"
    "op-test:$HOME/src/livesystems/openplatform/openplatform-test-suite:source .venv/bin/activate"
    "oa:$HOME/src/livesystems/openassets/openassets-orchestration"
    "oa-ai:$HOME/src/livesystems/openassets:claude"
    "cy:$HOME/src/livesystems/cysensic/cysensic-orchestration"
    "cy-ai:$HOME/src/livesystems/cysensic:claude"
    "spvs:$HOME/src/livesystems/spvs/openassets-orchestration"
    "lkp:$HOME/src/livesystems/lkp/lkp-orchestration"
    "ppas:$HOME/src/livesystems/ppas/ppas-orchestration"
    "ppas-ai:$HOME/src/livesystems/ppas:claude"
    "pre:$HOME/src/livesystems/pre/pre-orchestration"
    "pre-ai:$HOME/src/livesystems/pre:claude"
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
