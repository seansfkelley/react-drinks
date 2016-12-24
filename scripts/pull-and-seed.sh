#!/bin/sh

if [ -z "$1" ]
then
  echo "Usage: $0 <branch-name>"
  exit 0
fi

set -e

git fetch
git checkout "$1"

export NODE_ENV=production

npm install

.scripts/seed-database.js --force --include-custom-recipes
