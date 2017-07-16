#/usr/bin/env sh

set -ex -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIST=".dist"

cd "$DIR"
cd ..

# init

rm -r "$DIST"
mkdir "$DIST"

# js

BROWSERIFY_COMMAND='./node_modules/.bin/browserify --extension=tsx --extension=ts --extension=js -p tsify'

$BROWSERIFY_COMMAND frontend/endpoints/recipe/recipe-init.tsx  -o "$DIST/recipe-init.js"
$BROWSERIFY_COMMAND frontend/endpoints/app/app-init.tsx  -o "$DIST/app-init.js"

# css

ALL_STYLES="$DIST/all-styles.css"

touch "$ALL_STYLES"
cat ./node_modules/font-awesome/css/font-awesome.css >> "$ALL_STYLES"
./node_modules/stylus/bin/stylus styles/index.styl -p >> "$ALL_STYLES"
sed -i '' -e 's/\.\.\/fonts\//\.\fonts\//g' "$ALL_STYLES"

# static

cp -r fonts "$DIST"
cp -r ./node_modules/font-awesome/fonts "$DIST"
cp -r img "$DIST"
