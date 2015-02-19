gulp       = require 'gulp'
browserify = require 'gulp-browserify'
rename     = require 'gulp-rename'
stylus     = require 'gulp-stylus'
sourcemaps = require 'gulp-sourcemaps'

paths =
  root    : './frontend/test.cjsx'
  scripts : [ 'frontend/**/*.coffee', 'frontend/**/*.cjsx' ]
  styles  : [ 'styles/**/*.styl' ]

gulp.task 'scripts', ->
  gulp.src paths.root, { read : false }
    .pipe browserify {
      transform : [ require 'coffee-reactify' ]
      debug     : true
    }
    .pipe rename 'all-scripts.js'
    .pipe gulp.dest './.dist/'

gulp.task 'styles', ->
  gulp.src paths.styles
    .pipe sourcemaps.init()
    .pipe stylus()
    .pipe sourcemaps.write()
    .pipe rename 'all-styles.css'
    .pipe gulp.dest './.dist'

gulp.task 'watch', ->
  gulp.watch paths.scripts, [ 'scripts' ]
  gulp.watch paths.styles,  [ 'styles' ]

gulp.task 'default', [ 'scripts', 'styles', 'watch' ]
