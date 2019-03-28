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
    destination: basePath + dstFolder
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
        FRONTEND_URL: 'https://argu.localdev'
    }));

    return b.bundle()
        .pipe(source(bundleName))
        .pipe(buffer())
        .pipe(sourcemaps.init({loadMaps: true}))
        // Add transformation tasks to the pipeline here.
        //.pipe(uglify())
        .on('error', gutil.log)
        .pipe(sourcemaps.write('./'))
        .pipe(gulp.dest(src.destination));
}

function browserifyBundleStaging(bundleName, entryPoint) {
    var b = browserify(browserifyOptions(entryPoint));
    b.transform(envify({
        _: 'purge',
        FRONTEND_URL: 'https://leopard.argu.staging.c66.me',
        NODE_ENV: 'production'
    }), {
        global: true
    });

    return b.bundle()
        .pipe(source(bundleName))
        .pipe(buffer())
        // Add transformation tasks to the pipeline here.
        .on('error', gutil.log)
        .pipe(gulp.dest(src.destination));
}

function browserifyBundleProduction(bundleName, entryPoint) {
    var b = browserify(browserifyOptions(entryPoint));
    if (typeof process.env.FRONTEND_HOSTNAME === 'undefined') {
        throw new Error('NO FRONTEND_HOSTNAME GIVEN');
    }
    b.transform(envify({
        _: 'purge',
        FRONTEND_URL: `https://${process.env.FRONTEND_HOSTNAME}`,
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
        .pipe(gulp.dest(src.destination));
}

var bundles = [
  ['_bundle.js', 'App.js'],
  ['controllers/_container_nodes_bundle.js', 'controllers/container_nodes.js'],
  ['controllers/_info_bundle.js', 'controllers/info.js'],
  ['controllers/_pages_bundle.js', 'controllers/pages.js'],
  ['controllers/_static_pages_bundle.js', 'controllers/static_pages.js'],
  ['controllers/portal/_portal_bundle.js', 'controllers/portal/portal.js']
];

gulp.task('build', function () {
    bundles.forEach(bundle => {
        return browserifyBundle(bundle[0], bundle[1]);
    });
});

// Envified but not minified
gulp.task('build:staging', function () {
    bundles.forEach(bundle => {
        browserifyBundleStaging(bundle[0], bundle[1]);
    });
});

gulp.task('build:production', function () {
    bundles.forEach(bundle => {
        browserifyBundleProduction(bundle[0], bundle[1]);
    });
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
