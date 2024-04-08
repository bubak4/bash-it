function ls-git-repo-setup()
{
    git config user.name "martin.slouf"
    git config user.email "martin.slouf@livesystems.cz"
    git config pull.rebase false

    git config --list
}

function ls-git-add-remote()
{
    local remote_name=$1
    local remote_url=$2

    git remote add $remote_name $remote_url
    git remote -v
    echo "Press Enter to continue, Ctrl+C to exit..."
    read NOTHING
    git push $remote_name --all
    git push $remote_name --tags
}
