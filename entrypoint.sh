#!/bin/bash

set -e
set -x
set -eo pipefail

cd "$GITHUB_WORKSPACE"
echo "workdir: $GITHUB_WORKSPACE"

ls -al /workspace/imlonghao/aur

REPOS=$(git diff --dirstat=files,0 HEAD~1 | sed 's/^[ 0-9.]\+% //g' | sed 's/\/$//g')
DIRECTORY=$(pwd)

for REPO in $REPOS
do
    cd $DIRECTORY/$REPO/
    sudo makepkg --pr > .SRCINFO
done
