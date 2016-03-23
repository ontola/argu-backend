import Alert from '../src/app/components/Alert';
import { FastClick } from 'fastclick';
import Blazy from 'blazy';
import { safeCredentials, errorMessageForStatus } from '../src/app/lib/helpers';

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
            .on('ajax:success', ".timeline-component .timeline-point, .timeline-component .timeline-phase-title, .timeline-component .timeline-post-title", this.setActive)
            .on('turbolinks:load', this.handleDOMChangedFinished)
            .on('turbolinks:load', this.initPlaceholderFallback)
            .on('click', '.box-close-button', this.bannerHide)
            .on('cocoon:after-insert', this.handleAfterCocoonInstert)
            .ajaxComplete(this.handleAjaxCalls);

        window.addEventListener('online', this.handleOnline);
        window.addEventListener('offline', this.handleOffline);

        this.handleDOMChangedFinished();
        this.initPlaceholderFallback();
        $(window).resize(this.handleResizeBackground);
        this.handleResizeBackground();

        modal.init();
        FastClick.attach(document.body);

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
        $('.remote-link')
            .bind("ajax:beforeSend", function () {
                $(this).addClass("is-loading");
            })
            .bind('ajax:complete', function () {
                $(this).removeClass("is-loading");
            })
            .bind("ajax:error", function () {
                $(this).removeClass("is-loading");
            });
    },

    confirmInputHandler: function () {
        var _this = $(this);
        _this.closest('.confirm').find('.confirm-action').attr('disabled', _this.val() != _this.attr('confirm-text'));
    },

    disableSubmitButton: function () {
        var _this = $(this);
        _this.addClass("is-loading");
        setTimeout(function () {
            _this.removeClass("is-loading");
        }, 2500);
    },

    handleAfterCocoonInstert: function () {
        ReactRailsUJS.mountComponents()
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
        ui.handleEditableSettings();
        ui.bg = $(".background");
        $('button:submit').click(ui.disableSubmitButton);
        $("a[href*='#']:not([href='#'])[class~=smoothscroll]").click(ui.handleClickSmoothly);
        ui.bindRemoteLinks();
        new Blazy({
            offset: 100 // Loads images 100px before they're visible
        });
        $('.bg-img').bgLoaded({});
    },

    handleEditableSettings: function () {
        var settings;
        if ((settings = $('.portal-settings'))) {
            var editableOptions = {
                onsubmit: function (settings) {
                    settings.target = '/portal/settings/';
                },
                submitdata : function () {
                    return {key: this.getAttribute('id')};
                },
                indicator : 'Saving...',
                tooltip   : 'Click to edit...'
            };

            settings.find('.setting .value').editable('', editableOptions);

            settings.find('.add-setting').click(function () {
                var key = window.prompt('Enter the key', '');
                if (key !== null && key.length > 0) {
                    var newSetting = $('<tr class="setting"><td class="key">'+key+'</td><td class="value" id="'+key+'" title="Click to edit..."></td></tr>');
                    $('.settings-table tbody').append(newSetting);
                    newSetting.find('.value').editable('', editableOptions);
                }
            });
        }
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

export const modal = {
    init: function () {
        $(document)
            .on('click', '.modal-container:not(.no-close) .overlay', this.closeModal);

        // Close modal when pressing escape button
        // @TODO: Just listen to escape, not all the time all the buttons
        document.addEventListener('keyup', function(e) {
            if (e.keyCode == 27 && !$(".no-close")[0]) {
                $('.modal-container').addClass('modal-hide');
                window.setTimeout(function () {
                    $('.modal-container').remove();
                    $('body').removeClass('modal-opened');
                }, 500);
            }
        });
    },

    closeModal: function () {
        let container = $(this).parent('.modal-container');

        container.addClass('modal-hide');
        window.setTimeout(() => {
            container.remove();
            $('body').removeClass('modal-opened');
        }, 500);
    }
};
