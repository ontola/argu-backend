/* global $ */
import Blazy from 'blazy';
import { IMAGE_LOAD_OFFSET } from './ui';

let loading = false;
let reachedEnd = false;

const END_REACHED_TIMEOUT = 30000;

const activityFeed = {
  init: () => {
    $(document).on('click', '.activity-feed .load-more', activityFeed.loadMore);

    $(window).scroll(() => {
      if (!loading && !reachedEnd && ($(window).scrollTop() >
        $(document).height() - $(window).height() - 300)) {
        $('.activity-feed .load-more').click();
      }
    });
  },

  loadMore() {
    const jThis = $(this);
    const feedDOM = $('.activity-feed .activities');
    jThis.text('activities.ui.loading');
    loading = true;
    $.ajax('/activities.html', {
      data: {
        from_time: feedDOM.find('.activity:last time').attr('datetime'),
      },
      cache: false,
      success: (d, s, xhr) => {
        if (xhr.status === 200 || xhr.status === 304) {
          feedDOM.append(d);
          jThis.text('activities.ui.load_more');
          new Blazy({
            offset: IMAGE_LOAD_OFFSET,
          });
        } else if (xhr.status === 204) {
          jThis.text('activities.ui.no_more_activities');
          reachedEnd = true;
          window.setTimeout(() => {
            reachedEnd = false;
          }, END_REACHED_TIMEOUT);
        }
        loading = false;
      },
    });
  },
};

export default activityFeed;
