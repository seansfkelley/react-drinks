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

yarn

./node_modules/.bin/ts-node ./scripts/seed-database.ts --force --include-custom-recipes
