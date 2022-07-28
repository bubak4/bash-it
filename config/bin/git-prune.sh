#!/bin/bash
# Time-stamp: <2022-07-28 15:00:02 martin>
# taken from https://www.axllent.org/docs/purge-files-from-git/ and slightly modified

if [ "$#" -lt 1 ]; then
    echo "Usage: git-purge.sh <file/folder> [<file/folder>]"
    exit 2
fi

if [ "$1" == "-h" ]; then
    echo "Usage: git-purge.sh <file/folder> [<file/folder>]"
    exit
fi

echo "# added by 'git-prune.sh' at $(date --iso-8601)" > /tmp/gitignore

while [ -n "$1" ]; do
    FILENAME="$1"

    # Remove from all commits, then remove the refs to the old commits
    FILTER_BRANCH_SQUELCH_WARNING=1 \
    git filter-branch --index-filter 'git rm -rf --cached --ignore-unmatch '"${FILENAME}" --prune-empty --tag-name-filter cat -- --all
    git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d

    # Ensure all old refs are fully removed
    rm -Rf .git/logs .git/refs/original

    # Perform a garbage collection to remove commits with no refs
    git gc --prune=all --aggressive

    # Add only if not added already
    fgrep -e "/$FILENAME" .gitignore || echo "/$FILENAME" >> /tmp/gitignore

    rm -rf "$FILENAME"
    shift;
done

# Update .gitignore only if something has been added
number_of_lines=$(cat /tmp/gitignore  | wc -l)
if test $number_of_lines -gt 1 ; then
   cat /tmp/gitignore >> .gitignore
fi

git add .gitignore
git commit -m "Add paths to .gitignore"

# Compress local database
git reflog expire --expire=now --all && git gc --prune=now --aggressive 2> /dev/null

echo "Execute 'git push --force --all' to push these changes"
