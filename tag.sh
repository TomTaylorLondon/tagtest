#!/bin/bash
# Utility script to create tags based on version file
# verison file must be in the same directory as this script

# http://stackoverflow.com/questions/3878624/how-do-i-programmatically-determine-if-there-are-uncommited-changes
require_clean_work_tree () {
    # Update the index
    git update-index -q --ignore-submodules --refresh
    err=0

    # Disallow unstaged changes in the working tree
    if ! git diff-files --quiet --ignore-submodules --
    then
        echo >&2 "cannot $1: you have unstaged changes."
        git diff-files --name-status -r --ignore-submodules -- >&2
        err=1
    fi

    # Disallow uncommitted changes in the index
    if ! git diff-index --cached --quiet HEAD --ignore-submodules --
    then
        echo >&2 "cannot $1: your index contains uncommitted changes."
        git diff-index --cached --name-status -r --ignore-submodules HEAD -- >&2
        err=1
    fi

    if [ $err = 1 ]
    then
        echo >&2 "Please commit or stash them."
        exit 1
    fi
}

# load version from file and tag
VERSION=$(cat version)
# ensure the user is up-to-date
echo "checking workspace"
require_clean_work_tree
echo "creating tag $VERSION"
git tag -a $VERSION -m $VERSION
# on error (e.g. duplicate tag) exit
if [ $? -ne 0 ]; then
    exit $?
fi
# push
echo "pushing tag"
git push origin $VERSION
