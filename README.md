# Spirit Guide

A cocktail-mixing web app for your phone!

## Try It!

There is a version I keep mostly up-to-date at [104.236.188.87](104.236.188.87) (domain name forthcoming). It's tailored for Safari on iOS but generally seems to work elsewhere. Try saving it as a Web Clip from Safari to your home screen to remove the browser chrome and get a better experience.

## Features

### See what you can mix

Put in what ingredients you have, get a list of what you can make. Recipes are currently sourced from the IBA and random sites on the internet.

### Substitutions

Substitutions are accounted for when listing out mixable recipes -- have bourbon, but not rye? That Manhattan is still delicious. Cointreau, but not triple sec? You can make a Long Island Iced Tea, if you really want: the app leaves that decision up to you.

### Almost-mixable drinks

If you've ever gotten that sneaking suspicion that you were one cheap mixer away from making a whole bunch of drinks, you were probably right. Things that are only one or two ingredients away will still come up and call out what they're missing so you can decide what to get at the corner store.

### Curated ingredient/recipe lists

No longer do you have to enter all three of "Kahlua", "Tia Maria" and "coffee liqueur" to make sure you got all the results you should. The search understands that these are freely interchangable and will bring up the single representative -- "coffee liqueur" -- when you look for any of them.

## Setup

First:

    npm install
    npm install -g gulp

### Production:

    NODE_ENV=production gulp dist # Compile with minification.
    npm start                     # This will not auto-restart: you may want to wrap this with `forever` or similar.

### Development

Install the commit hooks:

    ./hooks/install.sh

Then run each in a separate terminal session:

    gulp watch  # Recompile assets on change. Start the livereload server.
    npm run dev # Restart server on backend code change.

Install the LiveReload browser extension to get live reloading behavior.

## Configuration

You can specify a port using the `PORT` environment variable: `PORT=80 npm start`.

## Using the App

When running, visit [localhost:8080](http://localhost:8080/).

On an iPhone, you can save the page as a Web Clip from Safari and access it from the home screen (it removes the browser chrome).
