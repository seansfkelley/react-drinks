#!/bin/sh

# This may fail.
forever stop index.coffee

# Anything else should not.
set -e

git fetch
git checkout origin/master

export NODE_ENV=production

npm install
gulp dist

PORT=80 forever start -c ./node_modules/.bin/coffee index.coffee --custom-recipes
