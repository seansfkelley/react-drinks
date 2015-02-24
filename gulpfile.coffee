gulp         = require 'gulp'
gutil        = require 'gulp-util'
rename       = require 'gulp-rename'
stylus       = require 'gulp-stylus'
postcss      = require 'gulp-postcss'
sourcemaps   = require 'gulp-sourcemaps'
concat       = require 'gulp-concat'
browserify   = require 'browserify'
watchify     = require 'watchify'
buffer       = require 'vinyl-buffer'
source       = require 'vinyl-source-stream'
autoprefixer = require 'autoprefixer-core'

paths =
  root    : [ './frontend/app.cjsx', './frontend/global.coffee' ]
  scripts : [ 'frontend/**/*.coffee', 'frontend/**/*.cjsx' ]
  styles  : [ 'styles/**/*.styl', 'styles/**/*.css' ]

bundler = watchify browserify paths.root, {
  extensions : [ '.coffee', '.cjsx' ]
  debug      : true
}
# https://github.com/substack/node-browserify/issues/1124
bundler.transform require 'coffee-reactify'

bundle = ->
  return bundler.bundle()
    .on 'error', gutil.log.bind(gutil, 'Browserify Error')
    .pipe source 'all-scripts.js'
    .pipe buffer()
    .pipe sourcemaps.init { loadMaps : true }
    .pipe sourcemaps.write './'
    .pipe gulp.dest './.dist'

bundler.on 'update', bundle
# TODO: This standalone should not be watchified cause it's really annoying.
gulp.task 'scripts', bundle

gulp.task 'styles', ->
  gulp.src paths.styles
    .pipe sourcemaps.init()
    .pipe stylus {
      include : [ __dirname + '/styles' ]
    }
    .pipe postcss [
      autoprefixer()
    ]
    .pipe sourcemaps.write()
    .pipe concat 'all-styles.css'
    .pipe gulp.dest './.dist'

gulp.task 'watch', ->
  bundle()
  gulp.watch paths.styles,  [ 'styles' ]

gulp.task 'default', [ 'styles', 'watch' ]
