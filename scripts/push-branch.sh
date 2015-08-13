#!/bin/sh

set -e

git fetch

if [[ "$(git rev-parse $1)" != "$(git rev-parse origin/$1)" ]]
then
  read -p 'Local $1 and remote have diverged. Continue? [y/N] ' -n 1 -r
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
      exit 0
  fi
  echo
fi

ssh root@104.236.188.87 'cd react-drinks-staging ; PORT=8080 ./scripts/pull.sh origin/$1'
