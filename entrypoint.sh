#!/bin/bash

set -x
set -e
set -eo pipefail

REPOS=$(sudo git diff --dirstat=files,0 HEAD~1 | sed 's/^[ 0-9.]\+% //g' | grep -v '^\.' | grep '/' | sed 's/\/$//g')
DIRECTORY=$(pwd)

for REPO in $REPOS
do
    cd $DIRECTORY/$REPO/
    sudo makepkg --pr | sudo tee .SRCINFO
done
