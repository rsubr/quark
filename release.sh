#!/bin/bash

# git commands shortcut to tag the current commit

ver="$1"

if [ -z "$ver" ]; then
  echo "Please provide a tag to replace"
  exit 1
fi

set -eoux pipefail

echo "Replace local tag ${ver} to reference latest commit"
git tag -fa "${ver}" -m "Release ${ver}"

echo "Deleting remote tag ${ver}"
git push --delete origin "${ver}"

echo "Pushing main branch to remote"
git push

echo "Pushing local tags to remote"
git push origin tag "${ver}"
