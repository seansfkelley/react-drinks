_            = require 'lodash'
gulp         = require 'gulp'
gulpif       = require 'gulp-if'
rename       = require 'gulp-rename'
replace      = require 'gulp-replace'
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
sourceStream = require 'vinyl-source-stream'
autoprefixer = require 'autoprefixer-core'

IS_PROD = process.env.NODE_ENV == 'production'

LIBRARY_CSS_PATHS = [
  'font-awesome/css/font-awesome.css'
  'react-draggable/lib/styles.css'
]

SRC_PATHS =
  scripts : [
    source      : './frontend/endpoints/app/app-init.cjsx'
    destination : 'app-init.js'
  ,
    source      : './frontend/endpoints/recipe/recipe-init.cjsx'
    destination : 'recipe-init.js'
  ]
  styles : [
    './styles/index.styl'
  ].concat _.map(LIBRARY_CSS_PATHS, (p) -> './node_modules/' + p)
  styleWatch : [
    './styles/**/*.styl'
  ]
  fonts : [
    './fonts/**.*'
    './node_modules/font-awesome/fonts/**.*'
  ]
  img : [
    './img/**.*'
  ]

copyAssets = ->
  gulp.src SRC_PATHS.fonts
    .pipe gulp.dest './.dist/fonts'

  gulp.src SRC_PATHS.img
    .pipe gulp.dest './.dist/img'

buildSingleScript  = ({ source, destination, watch, dieOnError }) ->
  bundler = browserify source, {
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
      .pipe sourceStream destination
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

buildScripts = (watch = false, dieOnError = false) ->
  for { source, destination } in SRC_PATHS.scripts
    buildSingleScript { source, destination, watch, dieOnError }
  return # for loop

buildStyles = ->
  gulp.src SRC_PATHS.styles
    .pipe sourcemaps.init { loadMaps : true }
    .pipe stylus()
    # TODO: Why doesn't this abort the stream like the Browserify one does?
    .on 'error', notify.onError {
      title : 'Stylus Error'
      sound : 'Sosumi'
    }
    .pipe postcss [
      autoprefixer()
    ]
    .pipe concat 'all-styles.css'
    .pipe replace '../fonts/', '/assets/fonts/'
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
  gulp.watch SRC_PATHS.styleWatch,  [ 'styles' ]
gulp.task 'dist', [ 'scripts', 'styles', 'assets' ]
gulp.task 'default', [ 'watch' ]
