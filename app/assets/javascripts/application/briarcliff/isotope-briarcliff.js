import Isotope from 'isotope-layout';

var $container;

// filter functions
var lastFilter = "";
var lastType   = "";

var filterFns = {
    // filter by tag using data-tags
    combined: function () {
        var correctTag,
            correctType;
        if(typeof lastFilter !== 'undefined' && lastFilter != '') {
            var tags = this.dataset.tags.split(',');
            correctTag = tags.indexOf(lastFilter) != -1;
        } else correctTag = true;

        if (lastType != "") correctType = this.className.indexOf(lastType) != -1;
        else correctType = true;

        return correctTag && correctType;
    }
};

export default function init () {
    checkForGrid();

    $(document).on('pjax:complete pjax:end', function () {
        checkForGrid();
    }).on('click', '.sort-random', function () {
        $container
            .arrange('updateSortData')
            .arrange({
                sortBy: 'random'
            });
    }).on('click', '#tags a', function (e) {
        // bind filter button click
        e.preventDefault();   // this prevents selecting the words in chrome on android
        var  _this = $(this),
            filter = _this.attr('data-filter'),
            value  = this.dataset.filterValue;
        filterForTag(value);
        history.pushState({filter: filter, filterValue: value}, value + 'header_title', _this.attr('data-forum-path')+'/t/' + value);
    }).on('click', '#type a', function (e) {
        e.preventDefault();   // this prevents selecting the words in chrome on android
        var  _this = $(this),
            filter = _this.attr('data-filter'),
            value  = this.dataset.filterValue || "";
        filterForType(filter, filter);
        if (filter == '') {
            history.pushState({
                filter: filter,
                filterValue: value
            }, value + 'header_title', _this.attr('data-forum-path') + '/' + value);
        }
    }).on('click', '#sorts a', function () {
        var sortValue = $(this).attr('data-sort-value');
        $container.arrange({ sortBy: sortValue });
    }).on('click', '#display [data-display-setting="info_bar"]', function () {
        let grid = $('.grid');
        grid.toggleClass( 'display-hide-details');
        grid.arrange();
    }).on('click', '#display [data-display-setting="image"]', function () {
        let grid = $('.grid');
        grid.toggleClass( 'display-hide-images');
        grid.arrange();
    }).on('click', '#display [data-display-setting="columns"]', function () {
        let grid = $('.grid');
        grid.toggleClass( 'display-single-column');
        grid.arrange();
    });

    // change is-checked class on buttons
    $('#sorts').each(function (i, buttonGroup) {
        var $buttonGroup = $(buttonGroup);
        $buttonGroup.on('click', 'a', function () {
            $buttonGroup.find('.is-checked').removeClass('is-checked');
            $(this).addClass('is-checked');
        });
    });

    window.onpopstate = function(event) {
        if ($('.grid').length > 0) {
            if (typeof $container.isotope !== 'function') {
                checkForGrid();
            }
            if (event.state) {
                event.state.filterValue = event.state.filterValue || '';
            }
            var state = event.state || {filterValue: ''};
            filterForTag(state.filterValue);
        }
    };
    if ($('.tags-bar')) {
        var tag =  '';//location.pathname.split('/')[1];
        if (tag !== null && tag !== "") {
            filterForTag(tag);
        }
    }
}

function checkForGrid () {
    let grid = document.querySelector('.grid');

    if (grid !== null) {
        $container = new Isotope(grid, {
            itemSelector: '.box-grid',
            columnWidth: '.box-grid-sizer',
            getSortData: {
                updated_at: '[data-updated-at]',
                created_at: '[data-created-at]',
                name: 'h2',
                vote_count: '[data-vote-count] parseInt'
            },
            sortAscending: {
                created_at: false,
                updated_at: false,
                name: true,
                vote_count: false
            }
        });
    }
}
var _document = $(document);

function activateFilter(type, filter, value) {
    $container.arrange({ filter: filterFns['combined'] });
    if ((filterFns[filter] || filter || '') == '') setHighlight('tags', '');
}

function filterForType(filter, value) {
    lastType = value;
    if (filter == "") lastFilter = "";
    activateFilter(filter, filter, value);
    setHighlight('type', value);
    if(lastFilter != "") activateFilter('tags', 'tags', lastFilter);
}

function filterForTag(tag) {
    lastFilter = tag;
    activateFilter('tags', 'tags', tag);
    setHighlight('tags', lastFilter);
    if(lastType != "") activateFilter('type', lastType, lastType);
}

function setHighlight(type, value) {
    _document.find('#' + type + ' .is-checked').removeClass('is-checked');
    _document.find('#' + type + ' [data-filter-value="'+value+'"]').addClass('is-checked');
}
