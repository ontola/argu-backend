import { introJs } from 'intro.js';
import I18n from 'i18n-js';

if(typeof I18n !== 'undefined') {
    I18n.locale = document.head.querySelector("[name=language]").content;
}

let introJsOptions = {
    'skipLabel': I18n.t('intro.skip'),
    'nextLabel': I18n.t('intro.next'),
    'prevLabel': I18n.t('intro.previous'),
    'doneLabel': I18n.t('intro.done'),
    'disableInteraction': false,
    'showBullets': true,
    'showProgress': false,
    'showStepNumbers': false,
    'scrollToElement': true
};

let introJsMotionTour = introJs().setOptions(introJsOptions).setOptions({
    steps:[
        {
            element: document.querySelector('.motion-body'),
            intro: I18n.t('intro.motion.posted.body')
        },
        {
            element: document.querySelector('.motion-votes'),
            intro: I18n.t('intro.motion.posted.vote')
        },
        {
            element: document.querySelector('.argument-columns'),
            intro: I18n.t('intro.motion.posted.post_argument')
        },
        {
            element: document.querySelector('.share-menu'),
            intro: I18n.t('intro.motion.posted.share')
        }
    ]
});

//start introJs after posting an idea
if (window.location.search.indexOf('start_motion_tour=true') > -1) {
    introJsMotionTour.start();
}

$(function() {
    $(document)
        // read all the introJs content on the page. May be deprecated.
        .on("click", '.intro-trigger', function () {
            introJs.start();
        })
        // Stops intro when user opens a new page.
        .on('pjax:click', function () {
            introJs().exit();
        });
});
