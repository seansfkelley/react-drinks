#!/bin/sh

# This may fail.
forever stop index.coffee

# Anything else should not.
set -e

git fetch
git checkout origin/master

npm install
PRODUCTION=true gulp dist

PORT=80 forever start -c ./node_modules/.bin/coffee index.coffee
