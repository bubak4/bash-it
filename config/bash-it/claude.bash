# Claude Code user config lives in this repo (config/etc/.claude/) and is symlinked into ~/.claude/.
# Claude Code saves settings.json by replacing the file, which turns the symlink back into a plain
# file — so on shell start, copy any such replaced file back into the repo and re-link it.
# Review the result with `git diff` in ~/.bash-it.

function claude-config-relink()
{
    local name repo_file live_file
    for name in settings.json statusline-command.sh ; do
        repo_file=$BASH_IT/config/etc/.claude/$name
        live_file=~/.claude/$name
        test -f "$repo_file" || continue
        if test -f "$live_file" && ! test -L "$live_file" ; then
            cp "$live_file" "$repo_file"
            echo "I: claude: ~/.claude/$name was replaced; copied back into bash-it and re-linked (check git diff)"
        fi
        if ! test -L "$live_file" ; then
            mkdir -p ~/.claude
            ln -sf "$repo_file" "$live_file"
        fi
    done
}

claude-config-relink
