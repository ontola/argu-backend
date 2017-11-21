/* globals $ */
import Alert from '../../../javascript/components/Alert';
import { FastClick } from 'fastclick';
import { modal } from './modal';
import Blazy from 'blazy';
import { safeCredentials, errorMessageForStatus } from '../../../javascript/components/lib/helpers';
import twReplace from '../../../../lib/assets/javascripts/twreplace';

const ui = {
    bg: $(".background"),
    window: null,

    init: function () {
        $(document)
            .on('keyup', '.confirm .confirm-text', this.confirmInputHandler)
            .on('click', '.comment .btn-reply', this.openCommentForm)
            .on('click', '.comment .btn-cancel', this.cancelCommentForm)
            .on("tap click", '.dropdown div:first', this.mobileTapTooCloseFix)
            .on('change', '.form-toggle input[type="radio"]', this.handleFormToggleClick)
            .on('click', '.welcome-video-hide', this.welcomeVideoHide)
            .on('click', '.welcome-video-overlay, .welcome-video-toggle', this.welcomeVideoToggle)
            .on('click', '.banner .box-close-button', this.bannerHide)
            .on('ajax:success', ".timeline-component .timeline-point, .timeline-component .timeline-post-title", this.setActive)
            .on('turbolinks:load', this.handleDOMChangedFinished)
            .on('turbolinks:load', this.initPlaceholderFallback)
            .on('turbolinks:request-end', this.checkVersionNumber)
            .on('click', '.box-close-button', this.bannerHide)
            .ajaxComplete(this.handleAjaxCalls);

        window.addEventListener('online', this.handleOnline);
        window.addEventListener('offline', this.handleOffline);

        this.handleDOMChangedFinished();
        this.initPlaceholderFallback();
        $(window).resize(this.handleResizeBackground);
        this.handleResizeBackground();

        modal.init();
        try {
            FastClick.attach(document.body);
        } catch (e) {
            console.error(e);
        }

        var bLazy = new Blazy({
            offset: 100 // Loads images 100px before they're visible
        });

        //CBC-fixes
        //Disable IE-touch selection on non-content items
        $(document).on('selectstart', '#navbar,.filter-and-sort,.tabs,.dropdown', function(e) { e.preventDefault(); });
    },

    bannerHide: function () {
        let banner = $(this).closest('.banner,.announcement');
        fetch('/banner_dismissals.json', safeCredentials({
            method: 'post',
            body: JSON.stringify({
                banner_dismissal: {
                    banner_id: banner.attr('id').split('_')[1]
                }
            })
        })).then(() => {
            banner.slideUp();
        });
    },

    bindRemoteLinks: function () {
        $(document)
            .on('ajax:beforeSend', 'a[data-remote=true], form[data-remote=true]', function () {
                $(this).addClass('is-loading');
            })
            .on('ajax:complete', 'a[data-remote=true], form[data-remote=true]', function () {
                if (!document.body.classList.contains('turbolinks-redirect')) {
                    $(this).removeClass('is-loading');
                }
            })
            .on('ajax:error', 'a[data-remote=true], form[data-remote=true]', function () {
                $(this).removeClass('is-loading');
            });
    },

    checkVersionNumber: function (event) {
        if (event.originalEvent.data.xhr.getResponseHeader('Argu-Version') !== null && event.originalEvent.data.xhr.getResponseHeader('Argu-Version') !== window.arguVersion) {
            if (window.confirm("A new version of Argu has been released. Would you like to reload this page? (recommended)") == true) {
                document.location.reload(true);
            }
        }
    },

    confirmInputHandler: function () {
        var _this = $(this);
        _this.closest('.confirm').find('.confirm-action').attr('disabled', _this.val() != _this.attr('confirm-text'));
    },

    handleAjaxCalls: function (e, xhr, options) {
        if (xhr.status !== 200 &&
            xhr.status !== 204 &&
            xhr.status !== 201 &&
            xhr.status !== 0 &&
            options.url.search(/facebook\.com|linkedin\.com/) == -1) {
            const message = errorMessageForStatus(xhr.status).fallback || `Unknown error occurred (status: ${xhr.status})`;
            new Alert(message, 'alert', true);
        }
    },

    handleClickSmoothly: function () {
        if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') && location.hostname == this.hostname) {
            var target = $(this.hash);
            target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
            if (target.length) {
                history.pushState(null, null, '#' + this.hash.slice(1));
                $('html,body').animate({
                    scrollTop: target.offset().top - 100
                }, 600);
                event.preventDefault();
            }
        }
    },

    handleDOMChangedFinished: function () {
        ui.bg = $(".background");
        $("a[href*='#']:not([href='#'])[class~=smoothscroll]").click(ui.handleClickSmoothly);
        ui.bindRemoteLinks();
        new Blazy({
            offset: 100 // Loads images 100px before they're visible
        });
        $('.bg-img').bgLoaded({});
        twReplace();
    },

    handleFormToggleClick: function () {
        var tmp=$(this).attr('name'),
                _this = $(this);
        $('input[name="'+tmp+'"]').parent("label").removeClass("checked");
        _this.parent("label").toggleClass("checked", this.selected);
        $(':not(.formtastic).argument').removeClass('side-pro side-con').addClass('side-' + _this.attr('value'));
    },

    handleOffline: function () {
        document.getElementById('onlineStatus').className = '';
    },

    handleOnline: function () {
        document.getElementById('onlineStatus').className = 'hidden';
    },

    handleResizeBackground: function () {
        "use strict";
        ui.bg.height($(window).height() + 0);
    },

    initPlaceholderFallback: function () {
        if (!('placeholder' in document.createElement("input"))) {
            $("input[placeholder], textarea[placeholder]").each(function () {
                var val = $(this).attr('placeholder');
                if ( this.value === '' ) {
                    this.value = val;
                }
                $(this).focus(function() {
                    if ( this.value === val ) {
                        this.value = '';
                    }
                }).blur(function() {
                    if ( $.trim(this.value) === '' ) {
                        this.value = val;
                    }
                })
            });

            // Clear default placeholder values on form submit
            $('form').submit(function() {
                $(this).find("input[placeholder], textarea[placeholder]").each(function() {
                    if ( this.value == $(this).attr('placeholder') ) {
                        this.value = '';
                    }
                });
            });
        }
    },

    // Prevents dropdown-active from opening the neighboring link in Chrome for android.. but also prevents clicking on dropdown content!
    mobileTapTooCloseFix: function (e) {
        e.preventDefault();
    },

    openCommentForm: function (e) {
        "use strict";
        e.preventDefault();
        $('.comment_form#cf' + $(this).data('comment-id')).slideToggle();
    },

    cancelCommentForm: function (e) {
        "use strict";
        e.preventDefault();
        $('#comments_' + $(this).data('comment-id')+' .box:first-child').show();
        $('#comments_' + $(this).data('comment-id')+' .box:last-child').remove();
    },

    setActive: function () {
        $(this).addClass('active');
    },

    welcomeVideoHide: function () {
        let videoElement = $('.welcome-video');
        videoElement
            .addClass('welcome-video-disappear')
            .removeClass('welcome-video-opened');
        $('body').removeClass('welcome-video-opened');

        setTimeout(() => {
            videoElement.remove();
        }, 1000);

        fetch('/persist_cookie.json', safeCredentials({
            method: 'put',
            body: JSON.stringify({
                user: {
                    key: 'hide_video',
                    value: 'true'
                }
            })
        }));
    },

    welcomeVideoToggle: function () {
        $('body, .welcome-video').toggleClass('welcome-video-opened');
    }

};

export default ui;
