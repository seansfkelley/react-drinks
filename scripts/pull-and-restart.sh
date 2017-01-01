#!/bin/sh

if [ -z "$1" ]
then
  echo "Usage: $0 <branch-name>"
  exit 0
fi

# This may fail.
forever stop ./index.ts

# Anything else should not.
set -e

git fetch
git checkout "$1"

yarn install
NODE_ENV=production gulp dist

forever start -c ./node_modules/.bin/ts-node ./index.ts
