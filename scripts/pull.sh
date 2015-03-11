#!/bin/sh

# This may fail.
forever stop index.coffee

# Anything else should not.
set -e

git fetch
git checkout origin/master

npm install
gulp dist

forever start -c coffee index.coffee
