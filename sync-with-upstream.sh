#!/bin/bash

# fetch from remote
git fetch upstream
# choose local branch
git checkout master
# merge from remote branch to local (current) branch
git merge upstream/master
# push
git push
# checkout feature/config
git checkout feature/config
# merge master
git merge master
