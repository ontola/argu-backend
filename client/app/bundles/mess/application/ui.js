/* global $, fetch */
import Alert from '../../Argu/components/Alert';
import attachFastClick from 'fastclick';
import Blazy from 'blazy';
import Turbolinks from 'turbolinks';
import { safeCredentials, errorMessageForStatus } from '../../Argu/lib/helpers';

const MODAL_TO_SAFE_REMOVE = 500;
const KEY_ESC = 27;

export const modal = {
  init() {
    Turbolinks.start();
    $(document)
            .on('click', '.modal-container:not(.no-close) .overlay', this.closeModal);

        // Close modal when pressing escape button
        // @TODO: Just listen to escape, not all the time all the buttons
    document.addEventListener('keyup', e => {
      if (e.keyCode === KEY_ESC && !$('.no-close')[0]) {
        $('.modal-container').addClass('modal-hide');
        window.setTimeout(() => {
          $('.modal-container').remove();
          $('body').removeClass('modal-opened');
        }, MODAL_TO_SAFE_REMOVE);
      }
    });
  },

  closeModal() {
    const container = $(this).parent('.modal-container');

    container.addClass('modal-hide');
    window.setTimeout(() => {
      container.remove();
      $('body').removeClass('modal-opened');
    }, 500);
  },
};

export const IMAGE_LOAD_OFFSET = 100;
const RESUBMIT_TIMEOUT = 2500;
const SMOOTH_OFFSET = 100;
const SMOOTH_ANIM_D = 600;
const TO_VIDEO_SAFE_REMOVE = 1000;


const ui = {
  bg: $('.background'),
  window: null,

  init() {
    $(document)
            .on('keyup', '.confirm .confirm-text', this.confirmInputHandler)
            .on('click', '.comment .btn-reply', this.openCommentForm)
            .on('click', '.comment .btn-cancel', this.cancelCommentForm)
            .on('tap click', '.dropdown div:first', this.mobileTapTooCloseFix)
            .on('change', '.form-toggle input[type="radio"]', this.handleFormToggleClick)
            .on('click', '.welcome-video-hide', this.welcomeVideoHide)
            .on('click', '.welcome-video-overlay, .welcome-video-toggle', this.welcomeVideoToggle)
            .on('click', '.banner .box-close-button', this.bannerHide)
            .on('ajax:success', '.timeline-component .timeline-point, ' +
                '.timeline-component .timeline-phase-title, ' +
                '.timeline-component .timeline-post-title', this.setActive)
            .on('turbolinks:load', this.handleDOMChangedFinished)
            .on('turbolinks:load', this.initPlaceholderFallback)
            .on('turbolinks:request-end', this.checkVersionNumber)
            .ajaxComplete(this.handleAjaxCalls);

    if (typeof window !== 'undefined') {
      window.addEventListener('online', this.handleOnline);
      window.addEventListener('offline', this.handleOffline);
      $(window).resize(this.handleResizeBackground);
    }

    this.handleDOMChangedFinished();
    this.initPlaceholderFallback();
    this.handleResizeBackground();

    modal.init();
    try {
      attachFastClick.attach(document.body);
    } catch (e) {
      console.error(e);
    }

    new Blazy({
      offset: IMAGE_LOAD_OFFSET,
    });

        // CBC-fixes
        // Disable IE-touch selection on non-content items
    $(document)
            .on('selectstart', '#navbar,.filter-and-sort,.tabs,.dropdown',
                e => {
                  e.preventDefault();
                }
            );
  },

  bannerHide() {
    const banner = $(this).closest('.banner,.announcement');
    fetch('/banner_dismissals.json', safeCredentials({
      method: 'post',
      body: JSON.stringify({
        banner_dismissal: {
          banner_id: banner.attr('id').split('_')[1],
        },
      }),
    })).then(() => {
      banner.slideUp();
    });
  },

  bindRemoteLinks() {
    $('.remote-link')
            .bind('ajax:beforeSend', e => {
              $(e.target).addClass('is-loading');
            })
            .bind('ajax:complete', e => {
              $(e.target).removeClass('is-loading');
            })
            .bind('ajax:error', e => {
              $(e.target).removeClass('is-loading');
            });
  },

  checkVersionNumber(event) {
    if (event.originalEvent.data.xhr.getResponseHeader('Argu-Version') !== null &&
      event.originalEvent.data.xhr.getResponseHeader('Argu-Version') !== window.arguVersion) {
      if (window.confirm('A new version of Argu has been released. Would you like to ' +
          'reload this page? (recommended)') === true) {
        document.location.reload(true);
      }
    }
  },

  confirmInputHandler() {
    const jThis = $(this);
    jThis
      .closest('.confirm')
      .find('.confirm-action')
      .attr('disabled', jThis.val() !== jThis.attr('confirm-text'));
  },

  disableSubmitButton() {
    const jThis = $(this);
    jThis.addClass('is-loading');
    setTimeout(() => {
      jThis.removeClass('is-loading');
    }, RESUBMIT_TIMEOUT);
  },

  handleAjaxCalls(_, xhr, options) {
    if (xhr.status !== 200 &&
            xhr.status !== 204 &&
            xhr.status !== 201 &&
            xhr.status !== 0 &&
            options.url.search(/facebook\.com|linkedin\.com/) === -1) {
      const message = errorMessageForStatus(xhr.status).fallback ||
        `Unknown error occurred (status: ${xhr.status})`;
      new Alert(message, 'alert', true);
    }
  },

  handleClickSmoothly() {
    if (location.pathname.replace(/^\//, '') === this.pathname.replace(/^\//, '') &&
          location.hostname === this.hostname) {
      let target = $(this.hash);
      target = target.length ? target : $(`[name=${this.hash.slice(1)}]`);
      if (target.length) {
        history.pushState(null, null, `#${this.hash.slice(1)}`);
        $('html,body').animate({
          scrollTop: target.offset().top - SMOOTH_OFFSET,
        }, SMOOTH_ANIM_D);
        event.preventDefault();
      }
    }
  },

  handleDOMChangedFinished() {
    ui.handleEditableSettings();
    ui.bg = $('.background');
    $('button:submit').click(ui.disableSubmitButton);
    $('a[href*=\'#\']:not([href=\'#\'])[class~=smoothscroll]').click(ui.handleClickSmoothly);
    ui.bindRemoteLinks();
    new Blazy({
      offset: IMAGE_LOAD_OFFSET,
    });
        // $('.bg-img').bgLoaded({});
  },

  handleEditableSettings() {
    const settings = $('.portal-settings');
    if (settings) {
      // const editableOptions = {
      //  onsubmit(newSettings) {
      //    newSettings.target = '/portal/settings/';
      //  },
      //  submitdata() {
      //    return { key: this.getAttribute('id') };
      //  },
      //  indicator: 'Saving...',
      //  tooltip: 'Click to edit...',
      // };

            // settings.find('.setting .value').editable('', editableOptions);

      settings.find('.add-setting').click(() => {
        const key = window.prompt('Enter the key', '');
        if (key !== null && key.length > 0) {
          const newSetting = $(`<tr class="setting"><td class="key">${key}</td>` +
                               `<td class="value" id="${key}" title="Click to edit..."></td></tr>`);
          $('.settings-table tbody').append(newSetting);
                    // newSetting.find('.value').editable('', editableOptions);
        }
      });
    }
  },

  handleFormToggleClick() {
    const tmp = $(this).attr('name');
    const jThis = $(this);
    $(`input[name="${tmp}"]`).parent('label').removeClass('checked');
    jThis.parent('label').toggleClass('checked', this.selected);
    $(':not(.formtastic).argument')
      .removeClass('side-pro side-con')
      .addClass(`side-${jThis.attr('value')}`);
  },

  handleOffline() {
    document.getElementById('onlineStatus').className = '';
  },

  handleOnline() {
    document.getElementById('onlineStatus').className = 'hidden';
  },

  handleResizeBackground() {
    ui.bg.height($(window).height() + 0);
  },

  initPlaceholderFallback() {
    if (!('placeholder' in document.createElement('input'))) {
      $('input[placeholder], textarea[placeholder]')
        .each((i, elem) => {
          const modElem = elem;
          const jElem = $(modElem);
          const val = jElem.attr('placeholder');
          if (this.value === '') {
            this.value = val;
          }
          jElem.focus(() => {
            if (modElem.value === val) {
              modElem.value = '';
            }
          }).blur(() => {
            if ($.trim(modElem.value) === '') {
              modElem.value = val;
            }
          });
        });

      // Clear default placeholder values on form submit
      $('form').submit(e => {
        $(e.target)
          .find('input[placeholder], textarea[placeholder]')
          .each((i, elem) => {
            const elemObj = elem;
            if (elemObj.value === $(elemObj).attr('placeholder')) {
              elemObj.value = '';
            }
          });
      });
    }
  },

  // Prevents dropdown-active from opening the neighboring link in Chrome for android
  // but also prevents clicking on dropdown content!
  mobileTapTooCloseFix(e) {
    e.preventDefault();
  },

  openCommentForm(e) {
    e.preventDefault();
    $(`.comment_form#cf${$(this).data('comment-id')}`).slideToggle();
  },

  cancelCommentForm(e) {
    e.preventDefault();
    $(`#comments_${$(this).data('comment-id')} .box:first-child`).show();
    $(`#comments_${$(this).data('comment-id')} .box:last-child`).remove();
  },

  setActive() {
    $(this).addClass('active');
  },

  welcomeVideoHide() {
    const videoElement = $('.welcome-video');
    videoElement
            .addClass('welcome-video-disappear')
            .removeClass('welcome-video-opened');
    $('body').removeClass('welcome-video-opened');

    setTimeout(() => {
      videoElement.remove();
    }, TO_VIDEO_SAFE_REMOVE);

    fetch('/persist_cookie.json', safeCredentials({
      method: 'put',
      body: JSON.stringify({
        user: {
          key: 'hide_video',
          value: 'true',
        },
      }),
    }));
  },

  welcomeVideoToggle() {
    $('body, .welcome-video').toggleClass('welcome-video-opened');
  },

};

export default ui;
