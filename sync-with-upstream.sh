#!/bin/bash

# fetch from remote
git fetch upstream
# choose local branch
git checkout master
# merge from remote branch to local (current) branch
git merge upstream/master
# push
git push
