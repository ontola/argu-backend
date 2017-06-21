/*global require:true */

var babel = require('gulp-babel');
var babelify = require('babelify');
var batch = require('gulp-batch');
var browserify = require('browserify');
var browserifyShim = require('browserify-shim');
var buffer = require('vinyl-buffer');
var bulkify = require('bulkify');
var deamdify = require('deamdify');
var eslint = require('gulp-eslint');
var envify = require('envify/custom');
var gulp = require('gulp');
var gutil = require('gulp-util');
var source = require('vinyl-source-stream');
var sourcemaps = require('gulp-sourcemaps');
var uglify = require('gulp-uglify');
var watch = require('gulp-watch');

var babelOpts = {};

var basePath = 'app/assets/javascripts/';
var srcFolder = 'src/';
var dstFolder = 'dist/';
var files = '**/*.js';

var src = {
    source: basePath + srcFolder + files,
    destination: basePath + dstFolder + srcFolder
};

function browserifyOptions(name) {
    return {
        entries: basePath + name,
        transform: [
            [babelify],
            [bulkify],
            [deamdify]
        ],
        exclude: [
            'jquery',
            'i18n-js'
        ]
    }
}

var lint = function (paths) {
    return gulp.src(paths.source)
        .pipe(eslint())
        .pipe(eslint.format())
        .pipe(eslint.failAfterError());
};

function browserifyBundle(bundleName, entryPoint) {
    var b = browserify(browserifyOptions(entryPoint));
    b.transform(envify({
        FRONTEND_URL: 'https://beta.argu.dev'
    }));

    return b.bundle()
        .pipe(source(bundleName))
        .pipe(buffer())
        .pipe(sourcemaps.init({loadMaps: true}))
        // Add transformation tasks to the pipeline here.
        //.pipe(uglify())
        .on('error', gutil.log)
        .pipe(sourcemaps.write('./'))
        .pipe(gulp.dest(basePath));
}

function browserifyBundleStaging(bundleName, entryPoint) {
    var b = browserify(browserifyOptions(entryPoint));
    b.transform(envify({
        _: 'purge',
        NODE_ENV: 'production'
    }), {
        global: true
    });

    return b.bundle()
        .pipe(source(bundleName))
        .pipe(buffer())
        // Add transformation tasks to the pipeline here.
        .on('error', gutil.log)
        .pipe(gulp.dest(basePath));
}

function browserifyBundleProduction(bundleName, entryPoint) {
    var b = browserify(browserifyOptions(entryPoint));
    b.transform(envify({
        _: 'purge',
        FRONTEND_URL: 'https://beta.argu.co',
        NODE_ENV: 'production'
    }), {
        global: true
    });

    return b.bundle()
        .pipe(source(bundleName))
        .pipe(buffer())
        // Add transformation tasks to the pipeline here.
        .pipe(uglify())
        .on('error', gutil.log)
        .pipe(gulp.dest(basePath));
}

gulp.task('build', function () {
    return browserifyBundle('_bundle.js', 'App.js');
});

gulp.task('build-components', function () {
    return browserifyBundle('_globbed_components.js', 'globbed_components.js');
});

// Envified but not minified
gulp.task('build:staging', function () {
    browserifyBundleStaging('_bundle.js', 'App.js');
});


// Envified but not minified
gulp.task('build-components:staging', function () {
    browserifyBundleStaging('_globbed_components.js', 'globbed_components.js');
});

gulp.task('build:production', function () {
    browserifyBundleProduction('_bundle.js', 'App.js');
});


gulp.task('build-components:production', function () {
    browserifyBundleProduction('_globbed_components.js', 'globbed_components.js');
});

gulp.task('lint-src', function () {
    return lint(src);
});

gulp.task('watch', function () {
    watch(src.source, batch(function (events, done) {
        gulp.start(['lint-src', 'build', 'build-components'], done);
    }));
});

gulp.task('default', ['watch']);
