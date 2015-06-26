_            = require 'lodash'
gulp         = require 'gulp'
gulpif       = require 'gulp-if'
rename       = require 'gulp-rename'
stylus       = require 'gulp-stylus'
postcss      = require 'gulp-postcss'
sourcemaps   = require 'gulp-sourcemaps'
concat       = require 'gulp-concat'
uglify       = require 'gulp-uglify'
minifyCss    = require 'gulp-minify-css'
notify       = require 'gulp-notify'
livereload   = require 'gulp-livereload'
filter       = require 'gulp-filter'
browserify   = require 'browserify'
watchify     = require 'watchify'
buffer       = require 'vinyl-buffer'
source       = require 'vinyl-source-stream'
autoprefixer = require 'autoprefixer-core'

IS_PROD = process.env.NODE_ENV == 'production'

LIBRARY_CSS_PATHS = [
  'font-awesome/css/font-awesome.css'
  'react-select/dist/default.css'
  'react-draggable/lib/styles.css'
]

SRC_PATHS =
  root    : [ './frontend/init.cjsx' ]
  scripts : [ './frontend/**/*.coffee', './frontend/**/*.cjsx' ]
  styles  : [
    './styles/**/*.styl'
    './styles/**/*.css'
  ].concat _.map(LIBRARY_CSS_PATHS, (p) -> './node_modules/' + p)
  # TODO: I'm sure there's a better way to do this: Stylus does its own concatenation now, so we should only process index.styl
  build_styles  : [
    './styles/index.styl'
  ].concat _.map(LIBRARY_CSS_PATHS, (p) -> './node_modules/' + p)
  fonts   : [
    './fonts/**.*'
    './node_modules/font-awesome/fonts/**.*'
  ]
  img     : [
    './img/**.*'
  ]

copyAssets = ->
  gulp.src SRC_PATHS.fonts
    .pipe gulp.dest './.dist/fonts'

  gulp.src SRC_PATHS.img
    .pipe gulp.dest './.dist/img'

buildScripts = (watch = false, dieOnError = false) ->
  bundler = browserify SRC_PATHS.root, {
    extensions   : [ '.coffee', '.cjsx' ]
    debug        : true
    cache        : {}
    packageCache : {}
    fullPaths    : watch
  }
  if watch
    bundler = watchify bundler

  # https://github.com/substack/node-browserify/issues/1124
  bundler.transform require 'coffee-reactify'

  rebundle = ->
    b = bundler.bundle()

    if not dieOnError
      b = b.on 'error', notify.onError {
        title : 'Browserify Error'
      }

    return b
      .pipe source 'all-scripts.js'
      .pipe buffer()
      .pipe sourcemaps.init { loadMaps : true }
      .pipe gulpif IS_PROD, uglify()
      .pipe notify {
        title   : 'Finished compiling Javascript'
        message : '<%= file.relative %>'
        wait    : true
      }
      .pipe sourcemaps.write './'
      .pipe gulp.dest './.dist'
      .pipe filter [ '*', '!*.map' ]
      .pipe livereload()

  bundler.on 'update', rebundle
  rebundle()

buildStyles = ->
  gulp.src SRC_PATHS.build_styles
    .pipe sourcemaps.init { loadMaps : true }
    .pipe stylus()
    # TODO: Why doesn't this abort the stream like the Browserify one does?
    .on 'error', notify.onError {
      title : 'Stylus Error'
      sound   : 'Sosumi'
    }
    .pipe postcss [
      autoprefixer()
    ]
    .pipe concat 'all-styles.css'
    .pipe gulpif IS_PROD, minifyCss()
    .pipe notify {
      title   : 'Finished compiling CSS'
      message : '<%= file.relative %>'
      wait    : true
      sound   : 'Glass'
    }
    .pipe sourcemaps.write './'
    .pipe gulp.dest './.dist'
    .pipe filter [ '*', '!*.map' ]
    .pipe livereload()

gulp.task 'assets', copyAssets
gulp.task 'scripts', -> buildScripts(false, true)
gulp.task 'styles', buildStyles
gulp.task 'watch', ->
  livereload.listen()
  copyAssets()
  buildScripts(true, false)
  buildStyles()
  gulp.watch SRC_PATHS.styles,  [ 'styles' ]
gulp.task 'dist', [ 'scripts', 'styles', 'assets' ]
gulp.task 'default', [ 'watch' ]
