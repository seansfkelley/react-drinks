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
browserify   = require 'browserify'
watchify     = require 'watchify'
buffer       = require 'vinyl-buffer'
source       = require 'vinyl-source-stream'
autoprefixer = require 'autoprefixer-core'

IS_PROD = process.env.NODE_ENV == 'production'

paths =
  root    : [ './frontend/init.cjsx' ]
  scripts : [ 'frontend/**/*.coffee', 'frontend/**/*.cjsx' ]
  styles  : [ 'styles/**/*.styl', 'styles/**/*.css' ]

makeBundler = ->
  b = browserify paths.root, {
    extensions : [ '.coffee', '.cjsx' ]
    debug      : true
  }
  # https://github.com/substack/node-browserify/issues/1124
  b.transform require 'coffee-reactify'
  return b

shouldDieOnBrowserifyError = true

generateBundlingFunction = (bundler) ->
  return ->
    b = bundler.bundle()

    if not shouldDieOnBrowserifyError
      b = b.on 'error', notify.onError {
        title : 'Browserify Error'
      }

    return b
      .pipe source 'all-scripts.js'
      .pipe buffer()
      .pipe sourcemaps.init { loadMaps : true }
      .pipe gulpif IS_PROD, uglify()
      .pipe notify {
        title   : 'Finished compiling Javscript'
        message : '<%= file.relative %>'
        wait    : true
      }
      .pipe sourcemaps.write './'
      .pipe gulp.dest './.dist'

buildStyles = ->
  gulp.src paths.styles
    .pipe sourcemaps.init { loadMaps : true }
    .pipe stylus {
      include : [ __dirname + '/styles' ]
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
    }
    .pipe sourcemaps.write './'
    .pipe gulp.dest './.dist'

buildScripts = ->
  shouldDieOnBrowserifyError = true
  generateBundlingFunction(makeBundler())()

buildAndWatchScripts = ->
  shouldDieOnBrowserifyError = false
  watchingBundler = watchify makeBundler()
  bundlingFunction = generateBundlingFunction(watchingBundler)
  bundlingFunction()
  watchingBundler.on 'update', bundlingFunction

gulp.task 'scripts', buildScripts
gulp.task 'styles', buildStyles
gulp.task 'watch', ->
  buildAndWatchScripts()
  buildStyles()
  gulp.watch paths.styles,  [ 'styles' ]
gulp.task 'dist', [ 'scripts', 'styles' ]
gulp.task 'default', [ 'watch' ]
