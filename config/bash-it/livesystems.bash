export GITLAB_URI=https://gitlab.livesystems.cz
# GITLAB_TOKEN lives in a git-crypt encrypted file; skipped while the repo is locked.
LS_SECRETS="$BASH_IT/config/secrets/livesystems.env"
if test -f "$LS_SECRETS" && ! head -c 9 "$LS_SECRETS" | grep -q GITCRYPT ; then
    source "$LS_SECRETS"
fi

# openplatform
PATH="$HOME/src/livesystems/openplatform/openplatform-orchestration/docker:$PATH"
if command -v op >/dev/null ; then
    eval "$(op completion bash)"
fi

# live-model
PATH="$HOME/.live-model/bin:$PATH"
LM_COMPLETION="$HOME/.live-model/etc/lm-completion.bash"
if test -f "$LM_COMPLETION" ; then
    source "$LM_COMPLETION"
fi

function ls-git-repo-setup()
{
    git config user.name "martin.slouf"
    git config user.email "martin.slouf@livesystems.cz"
    git config pull.rebase false

    # git config --list --show-scope
    repo_url=$(git remote -v | head -1 | awk '{print $2}')
    repo_email=$(git config --get user.email)
    echo -e "repo: $repo_url\t$repo_email"
}

function ls-git-dir-setup()
{
    for i in $(find -name .git) ; do
        target=$(dirname $(realpath $i))
        cd $target && ls-git-repo-setup && cd - > /dev/null
    done
}

function ls-git-add-remote()
{
    local remote_name=$1
    local remote_url=$2

    if test -z "$remote_name" -o -z "$remote_url"; then
        echo "Usage: ls-git-add-remote <remote_name> <remote_url>"
        return 1
    fi

    git remote add $remote_name $remote_url
    git remote -v
    echo "Press Enter to continue, input 'y' to push to new remote, Ctrl+C to exit..."
    read ANSWER
    if test "$ANSWER" = "y"; then
        git push $remote_name --all
        git push $remote_name --tags
    fi
}

function ls-git-repo-clone()
{
    local repo_name=$1

    if test -z "$repo_name"; then
        echo "Usage: ls-git-repo-clone <repo_name>"
        return 1
    fi

    glab repo clone ${repo_name} -a=false -p --paginate
}

function ls-git-group-clone()
{
    local group_name=$1

    if test -z "$group_name"; then
        echo "Usage: ls-git-group-clone <group_name>"
        return 1
    fi

    glab repo clone -g ${group_name} -a=false -p --paginate

    # repo setup
    cd ${group_name} && ls-git-dir-setup
}

function ls-ssh-keygen()
{
    local name=$1
    local email=${2:-"info@livesystems.cz"}
    local keyfile=${3:-"$name"}
    local bitsize=${4:-4096}

    if test -z "$name"; then
        echo "Usage: ls-ssh-keygen <name> [email] [keyfile] [bitsize]"
        return 1
    fi

    keyfile="$HOME/.ssh/livesystems-$keyfile"

    # generate RSA key
    ssh-keygen -t rsa -b $bitsize -C $email -f $keyfile

    ls -l ${keyfile}*
}
