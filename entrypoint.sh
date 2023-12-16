#!/bin/bash

set -eo pipefail

REPOS=$(sudo git diff --dirstat=files,0 HEAD~1 | sed 's/^[ 0-9.]\+% //g' | grep -v '^.' | sed 's/\/$//g')
DIRECTORY=$(pwd)

for REPO in $REPOS
do
    cd $DIRECTORY/$REPO/
    makepkg --pr | tee .SRCINFO
done
