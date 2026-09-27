#!/usr/bin/env bash
# Claude Code statusline: model, git branch (+ dirty count), context-window fullness.
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name')
dir=$(echo "$input" | jq -r '.workspace.current_dir')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Repos this statusline reports on: the repo containing $dir, or — in a multi-repo group dir that
# is not a repo itself — every child repo.
toplevel=$(git -C "$dir" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
if [ -n "$toplevel" ]; then
    repos=("$toplevel")
    branch=$(git -C "$toplevel" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
else
    repos=()
    for head in "$dir"/*/.git/HEAD; do
        [ -f "$head" ] && repos+=("${head%/.git/HEAD}")
    done
    # Prevailing branch: "dev" when all agree, "dev 23/31" when some are elsewhere. Reads
    # .git/HEAD directly, so it stays cheap on every redraw.
    branch=$(for repo in "${repos[@]}"; do
                 sed -n 's|^ref: refs/heads/||p' "$repo/.git/HEAD"
             done | sort | uniq -c | sort -rn | awk '
                 { total += $1; if (NR == 1) { top = $2; n = $1 } }
                 END { if (total) print (n == total ? top : top " " n "/" total) }')
fi

# Dirty count (modified or untracked) needs `git status` per repo — too slow for every redraw
# across a whole group, so it is cached and refreshed in the background once the cache is older
# than DIRTY_TTL seconds. A redraw never waits for it; it shows the last known value.
DIRTY_TTL=15
dirty=""
if [ ${#repos[@]} -gt 0 ]; then
    cache_dir="${XDG_RUNTIME_DIR:-/tmp}/claude-statusline"
    mkdir -p "$cache_dir"
    key=$(printf '%s' "$dir" | md5sum | cut -c1-16)
    cache="$cache_dir/$key.dirty"
    lock="$cache_dir/$key.lock"
    [ -f "$cache" ] && dirty=$(cat "$cache")
    age=$(( $(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0) ))
    # A lock older than a minute belongs to a refresh that died; clear it.
    find "$lock" -maxdepth 0 -mmin +1 -exec rmdir {} \; 2>/dev/null
    if [ "$age" -ge "$DIRTY_TTL" ] && mkdir "$lock" 2>/dev/null; then
        (
            n=0
            for repo in "${repos[@]}"; do
                [ -n "$(git -C "$repo" --no-optional-locks status --porcelain 2>/dev/null | head -1)" ] && n=$((n + 1))
            done
            echo "$n" > "$cache.tmp" && mv "$cache.tmp" "$cache"
            rmdir "$lock"
        ) </dev/null >/dev/null 2>&1 &
        disown
    fi
fi

printf '\033[2m%s\033[0m' "$model"

if [ -n "$branch" ]; then
    printf ' \033[2m|\033[0m \033[2m%s\033[0m' "$branch"
    if [ -n "$dirty" ] && [ "$dirty" -gt 0 ]; then
        if [ -n "$toplevel" ]; then
            printf '\033[2m*\033[0m'
        else
            printf ' \033[2m· %s dirty\033[0m' "$dirty"
        fi
    fi
fi

if [ -n "$used" ]; then
    printf ' \033[2m|\033[0m \033[2mctx %.0f%%\033[0m' "$used"
fi
