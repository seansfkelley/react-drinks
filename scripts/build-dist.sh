#/usr/bin/env sh

set -e -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIST=".dist"

cd "$DIR"
cd ..

echo "building from $(pwd)"

echo "emptying previous dist folder..."

rm -r "$DIST"
mkdir "$DIST"

echo "building scripts..."

BROWSERIFY='./node_modules/.bin/browserify --extension=tsx --extension=ts --extension=js -p tsify'

$BROWSERIFY frontend/endpoints/recipe/recipe-init.tsx  -o "$DIST/recipe-init.js"
$BROWSERIFY frontend/endpoints/app/app-init.tsx  -o "$DIST/app-init.js"

echo "building styles..."

ALL_STYLES="$DIST/all-styles.css"

touch "$ALL_STYLES"
cat ./node_modules/font-awesome/css/font-awesome.css >> "$ALL_STYLES"
./node_modules/stylus/bin/stylus styles/index.styl -p >> "$ALL_STYLES"
cat "$ALL_STYLES" | sed -e 's/\.\.\/fonts\//\.\/fonts\//g' > "$ALL_STYLES"

echo "copying static assets..."

cp -r fonts "$DIST"
cp -r ./node_modules/font-awesome/fonts "$DIST"
cp -r img "$DIST"

echo "done!"
