/* global I18n */
import { introJs } from 'intro.js';

const introJsOptions = {
    'skipLabel': I18n.t('intro.skip'),
    'nextLabel': I18n.t('intro.next'),
    'prevLabel': I18n.t('intro.previous'),
    'doneLabel': I18n.t('intro.done'),
    'disableInteraction': false,
    'showBullets': true,
    'showProgress': false,
    'showStepNumbers': false,
    'scrollToElement': true,
    'tooltipPosition': 'bottom-middle-aligned'
};

$(function() {
    //start introJs after posting an idea
    if (window.location.search.indexOf('start_motion_tour=true') > -1) {
        // For some weird reason, IntroJS does not listen to default tooltipPosition, so I added the position manually to all steps.
        introJs()
            .setOptions(introJsOptions)
            .setOptions({
                steps: [
                    {
                        element: document.querySelector('.motion-body'),
                        intro: I18n.t('intro.motion.posted.body'),
                        position: 'bottom-middle-aligned'
                    },
                    {
                        element: document.querySelector('.motion-votes'),
                        intro: I18n.t('intro.motion.posted.vote'),
                        position: 'bottom'
                    },
                    {
                        element: document.querySelector('.argument-columns'),
                        intro: I18n.t('intro.motion.posted.post_argument'),
                        position: 'bottom-middle-aligned'
                    },
                    {
                        element: document.querySelector('.share-menu'),
                        intro: I18n.t('intro.motion.posted.share'),
                        position: 'bottom-right-aligned'
                    }
                ]
            })
            .start();
    }

    $(document)
        // read all the introJs content on the page. May be deprecated.
        .on("click", '.intro-trigger', function () {
            introJs.start();
        })
        // Stops intro when user opens a new page.
        .on('turbolinks:click', function () {
            introJs().exit();
        });
});
