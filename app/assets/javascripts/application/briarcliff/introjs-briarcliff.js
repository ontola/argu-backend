import { introJs } from 'intro.js';

let introJsOptions = {
    'skipLabel': 'intro.skip',
    'nextLabel': 'intro.next',
    'prevLabel': 'intro.previous',
    'doneLabel': 'intro.done',
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
            intro: 'intro.motion.posted.body'
        },
        {
            element: document.querySelector('.motion-votes'),
            intro: 'intro.motion.posted.vote'
        },
        {
            element: document.querySelector('.argument-columns'),
            intro: 'intro.motion.posted.post_argument'
        },
        {
            element: document.querySelector('.share-menu'),
            intro: 'intro.motion.posted.share'
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
