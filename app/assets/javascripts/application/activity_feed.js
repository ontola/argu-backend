/* global I18n */
import Blazy from 'blazy';

let loading = false;
let reachedEnd = false;

const activityFeed = {
    init: () => {
        $(document).on('click', '.activity-feed .load-more', activityFeed.loadMore);
        $(document).on('change', '#feed_page_id', activityFeed.changeIri);

        $(window).scroll(() => {
            if (!loading && !reachedEnd && ($(window).scrollTop() > $(document).height() - $(window).height() - 300)) {
                activityFeed.triggerLoadMore();
            }
        });

        $(document).on('turbolinks:load', activityFeed.triggerLoadMore);

        window.setTimeout(activityFeed.triggerLoadMore, 0);
    },

    changeIri: function () {
        $('.activities .activity').remove();
        $('.activities').attr('data-feed-url', this.value);
        activityFeed.triggerLoadMore();
    },

    triggerLoadMore: function() {
        $('.activity-feed .load-more').click();
    },

    loadMore: function () {
        if (loading === false) {
            var _this   = $(this),
                feedDOM = $('.activity-feed .activities');
            _this.text(I18n.t('activities.ui.loading'));
            loading = true;
            $.ajax(feedDOM.attr('data-feed-url'), {
                data: {
                    'from_time': feedDOM.find('.activity:last time').attr('datetime'),
                    'complete': feedDOM.attr('data-feed-complete')
                },
                dataType: 'html',
                cache: false,
                success: (d, s, xhr) => {
                    if (xhr.status == 200 || xhr.status == 304) {
                        feedDOM.append(d);
                        ReactRailsUJS.mountComponents(".activity-feed");
                        _this.text(I18n.t('activities.ui.load_more'));
                        var bLazy = new Blazy({
                            offset: 100 // Loads images 100px before they're visible
                        });
                    } else if (xhr.status == 204) {
                        _this.text(I18n.t('activities.ui.no_more_artivities'));
                        reachedEnd = true;
                        window.setTimeout(() => {
                            reachedEnd = false;
                        }, 30*1000);
                    }
                    loading = false;
                }
            });
        }
    }
};


export default activityFeed
;
