import {} from 'lodash';
const gulp = require('gulp');
const gulpif = require('gulp-if');
const rename = require('gulp-rename');
const replace = require('gulp-replace');
const stylus = require('gulp-stylus');
const postcss = require('gulp-postcss');
const sourcemaps = require('gulp-sourcemaps');
const concat = require('gulp-concat');
const uglify = require('gulp-uglify');
const minifyCss = require('gulp-minify-css');
const notify = require('gulp-notify');
const livereload = require('gulp-livereload');
const filter = require('gulp-filter');
const browserify = require('browserify');
const watchify = require('watchify');
const buffer = require('vinyl-buffer');
const sourceStream = require('vinyl-source-stream');
const autoprefixer = require('autoprefixer-core');

const IS_PROD = process.env.NODE_ENV === 'production';

const LIBRARY_CSS_PATHS = ['font-awesome/css/font-awesome.css', 'react-draggable/lib/styles.css'];

const SRC_PATHS = {
  scripts: [{
    source: './frontend/endpoints/app/app-init.tsx',
    destination: 'app-init.js'
  }, {
    source: './frontend/endpoints/recipe/recipe-init.tsx',
    destination: 'recipe-init.js'
  }],
  styles: ['./styles/index.styl'].concat(_.map(LIBRARY_CSS_PATHS, p => `./node_modules/${ p }`)),
  styleWatch: ['./styles/**/*.styl'],
  fonts: ['./fonts/**.*', './node_modules/font-awesome/fonts/**.*'],
  img: ['./img/**.*']
};

const copyAssets = function () {
  gulp.src(SRC_PATHS.fonts).pipe(gulp.dest('./.dist/fonts'));

  return gulp.src(SRC_PATHS.img).pipe(gulp.dest('./.dist/img'));
};

const buildSingleScript = function ({ source, destination, watch, dieOnError }) {
  let bundler = browserify(source, {
    extensions: ['.js', '.ts', '.tsx'],
    debug: true,
    cache: {},
    packageCache: {},
    fullPaths: watch,
    plugin: [require('tsify')]
  });

  if (watch) {
    bundler = watchify(bundler);
  }

  const rebundle = function () {
    let b = bundler.bundle();

    if (!dieOnError) {
      b = b.on('error', notify.onError({
        title: 'Browserify Error',
        sound: 'Sosumi'
      }));
    }

    return b.pipe(sourceStream(destination)).pipe(buffer()).pipe(sourcemaps.init({ loadMaps: true })).pipe(gulpif(IS_PROD, uglify())).pipe(notify({
      title: 'Finished compiling Javascript',
      message: '<%= file.relative %>'
    })).pipe(sourcemaps.write('./')).pipe(gulp.dest('./.dist')).pipe(filter(['*', '!*.map'])).pipe(livereload());
  };

  bundler.on('update', rebundle);
  return rebundle();
};

const buildScripts = function (watch = false, dieOnError = false) {
  for (let { source, destination } of SRC_PATHS.scripts) {
    buildSingleScript({ source, destination, watch, dieOnError });
  } // for loop
};

const buildStyles = () => gulp.src(SRC_PATHS.styles).pipe(sourcemaps.init({ loadMaps: true })).pipe(stylus())
// TODO: Why doesn't this abort the stream like the Browserify one does?
.on('error', notify.onError({
  title: 'Stylus Error',
  sound: 'Sosumi'
})).pipe(postcss([autoprefixer()])).pipe(concat('all-styles.css')).pipe(replace('../fonts/', '/assets/fonts/')).pipe(gulpif(IS_PROD, minifyCss())).pipe(notify({
  title: 'Finished compiling CSS',
  message: '<%= file.relative %>',
  sound: 'Glass'
})).pipe(sourcemaps.write('./')).pipe(gulp.dest('./.dist')).pipe(filter(['*', '!*.map'])).pipe(livereload());

gulp.task('assets', copyAssets);
gulp.task('scripts', () => buildScripts(false, true));
gulp.task('styles', buildStyles);
gulp.task('watch', function () {
  livereload.listen();
  copyAssets();
  buildScripts(true, false);
  buildStyles();
  return gulp.watch(SRC_PATHS.styleWatch, ['styles']);
});
gulp.task('dist', ['scripts', 'styles', 'assets']);
gulp.task('default', ['watch']);

