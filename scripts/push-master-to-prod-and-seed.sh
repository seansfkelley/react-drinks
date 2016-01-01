#!/bin/sh

set -e

git fetch

if [[ "$(git rev-parse master)" != "$(git rev-parse origin/master)" ]]
then
  read -p 'Local master and remote master have diverged. Continue? [y/N] ' -n 1 -r
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
      exit 0
  fi
  echo
fi

ssh root@104.236.188.87 'cd react-drinks ; PORT=80 NODE_ENV=production ./scripts/pull-and-seed.sh origin/master'
