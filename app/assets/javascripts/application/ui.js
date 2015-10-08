import { safeCredentials } from '../lib/helpers';

export const ui = {
    bg: $(".background"),
    window: null,

    init: function () {
        "use strict";
        $(document)
            .on('keyup', '.confirm .confirm-text', this.confirmInputHandler)
            .on('click', '.comment .btn-reply', this.openCommentForm)
            .on('click', '.comment .btn-cancel', this.cancelCommentForm)
            .on('pjax:success', this.handleDOMChangedFinished)
            .on('pjax:end', this.checkTabs)
            .on("tap click", '.dropdown div:first', this.mobileTapTooCloseFix)
            .on('change', '.form-toggle input[type="radio"]', this.handleFormToggleClick)
            .ajaxComplete(this.handleAjaxCalls)
            .on('click', '.welcome-video-hide', this.welcomeVideoHide)
            .on('click', '.welcome-video-overlay, .welcome-video-toggle', this.welcomeVideoToggle);

        window.addEventListener('online', this.handleOnline);
        window.addEventListener('offline', this.handleOffline);

        this.handleDOMChangedFinished();
        this.initPlaceholderFallback();
        $(window).resize(this.handleResizeBackground);
        this.handleResizeBackground();

        modal.init();
        progressbar.init();
        FastClick.attach(document.body);

        //CBC-fixes
        //Disable IE-touch selection on non-content items
        $(document).on('selectstart', '#navbar,.filter-and-sort,.tabs,.dropdown', function(e) { e.preventDefault(); });
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
        "use strict";
        var _this = $(this);
        console.log(_this.attr('confirm-text'), _this.val());
        _this.closest('.confirm').find('.confirm-action').attr('disabled', _this.val() != _this.attr('confirm-text'));
    },

    disableSubmitButton: function () {
        var _this = $(this);
        _this.addClass("is-loading");
        setTimeout(function () {
            _this.removeClass("is-loading");
        }, 2500);
    },

    handleAjaxCalls: function (e, xhr, options) {
        if (xhr.status !== 200 && xhr.status !== 204 && xhr.status !== 201) {
            if (xhr.status === 401) {
                new Argu.Alert('Je moet ingelogd zijn voor deze actie.', 'alert', true);
            } else if (xhr.status === 404) {
                new Argu.Alert('Het item is niet gevonden, probeer de pagina te verversen.', 'alert', true);
            } else if (xhr.status === 429) {
                new Argu.Alert('Je maakt te veel verzoeken, probeer het over halve minuut nog eens.', 'alert', true);
            } else {
                new Argu.Alert('');
            }
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
        $('a[href*=#]:not([href=#])[class~=smoothscroll]').click(ui.handleClickSmoothly);
        ui.bindRemoteLinks();
        $('.bg-img').bgLoaded({});
    },

    handleEditableSettings: function () {
        "use strict";
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
        "use strict";
        if ( !("placeholder" in document.createElement("input")) ) {
            $("input[placeholder], textarea[placeholder]").each(function() {
                var val = $(this).attr("placeholder");
                if ( this.value == "" ) {
                    this.value = val;
                }
                $(this).focus(function() {
                    if ( this.value == val ) {
                        this.value = "";
                    }
                }).blur(function() {
                    if ( $.trim(this.value) == "" ) {
                        this.value = val;
                    }
                })
            });

            // Clear default placeholder values on form submit
            $('form').submit(function() {
                $(this).find("input[placeholder], textarea[placeholder]").each(function() {
                    if ( this.value == $(this).attr("placeholder") ) {
                        this.value = "";
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

export const modal = {
    init: function () {
        $(document)
            .on('click', '.modal-container:not(.no-close) .overlay', this.closeModal)
            .on('pjax:complete', function () {
                $('body').removeClass('modal-opened');
            });

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

export const progressbar = {
    init: function () {
        $(document)
            .on('pjax:start ajax:beforeSend',   NProgress.start)
            .on('pjax:success pjax:end ajax:complete',  NProgress.done)
            .on('pjax:end ajax:after', NProgress.remove);
    }
};
