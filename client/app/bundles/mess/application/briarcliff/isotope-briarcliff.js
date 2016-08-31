/* global $ */

import Isotope from 'isotope-layout';

const jDocument = $(document);
let $container;

// filter functions
let lastFilter = '';
let lastType = '';

function combinedFilter(elem) {
  let correctTag;
  let correctType;
  if (typeof lastFilter !== 'undefined' && lastFilter !== '') {
    const tags = elem.dataset.tags.split(',');
    correctTag = tags.indexOf(lastFilter) !== -1;
  } else {
    correctTag = true;
  }

  if (lastType !== '') {
    correctType = elem.className.indexOf(lastType) !== -1;
  } else {
    correctType = true;
  }

  return correctTag && correctType;
}

function checkForGrid() {
  const grid = document.querySelector('.grid');

  if (grid !== null) {
    $container = new Isotope(grid, {
      itemSelector: '.box-grid',
      columnWidth: '.box-grid-sizer',
      getSortData: {
        updated_at: '[data-updated-at]',
        created_at: '[data-created-at]',
        name: 'h2',
        vote_count: '[data-vote-count] parseInt',
      },
      sortAscending: {
        created_at: false,
        updated_at: false,
        name: true,
        vote_count: false,
      },
    });
  }
}

function setHighlight(type, value) {
  jDocument.find(`#${type} .is-checked`).removeClass('is-checked');
  jDocument.find(`#${type} [data-filter-value="${value}"]`).addClass('is-checked');
}

function activateFilter(_type, filter) {
  $container.arrange({ filter: combinedFilter });
  if ((filter || '') === '') {
    setHighlight('tags', '');
  }
}

function filterForType(filter, value) {
  lastType = value;
  if (filter === '') {
    lastFilter = '';
  }
  activateFilter(filter, filter, value);
  setHighlight('type', value);
  if (lastFilter !== '') {
    activateFilter('tags', 'tags', lastFilter);
  }
}

function filterForTag(tag) {
  lastFilter = tag;
  activateFilter('tags', 'tags', tag);
  setHighlight('tags', lastFilter);
  if (lastType !== '') {
    activateFilter('type', lastType, lastType);
  }
}

export default function init() {
  checkForGrid();

  $(document).on('turbolinks:load', () => {
    checkForGrid();
  })
    .on('click', '.sort-random', () => {
      $container
              .arrange('updateSortData')
              .arrange({
                sortBy: 'random',
              });
    })
    .on('click', '#tags a', e => {
      // bind filter button click
      // this prevents selecting the words in chrome on android
      e.preventDefault();
      const jThis = $(e.target);
      const filter = jThis.attr('data-filter');
      const value = e.target.dataset.filterValue;
      filterForTag(value);
      history.pushState(
              { filter, filterValue: value },
              `${value}header_title`,
              `${jThis.attr('data-forum-path')}/t/${value}`);
    })
    .on('click', '#type a', e => {
      // this prevents selecting the words in chrome on android
      e.preventDefault();
      const jThis = $(e.target);
      const filter = jThis.attr('data-filter');
      const value = e.target.dataset.filterValue || '';
      filterForType(filter, filter);
      if (filter === '') {
        history.pushState(
                  { filter, filterValue: value },
                  `${value}header_title`,
                  `${jThis.attr('data-forum-path')}/${value}`);
      }
    })
    .on('click', '#sorts a', e => {
      const sortValue = $(e.target).attr('data-sort-value');
      $container.arrange({ sortBy: sortValue });
    })
    .on('click', '#display [data-display-setting="info_bar"]', () => {
      const grid = $('.grid');
      grid.toggleClass('display-hide-details');
      $container.arrange();
    })
    .on('click', '#display [data-display-setting="image"]', () => {
      const grid = $('.grid');
      grid.toggleClass('display-hide-images');
      $container.arrange();
    })
    .on('click', '#display [data-display-setting="columns"]', () => {
      const grid = $('.grid');
      grid.toggleClass('display-single-column');
      $container.arrange();
    });

    // change is-checked class on buttons
  $('#sorts').each((i, buttonGroup) => {
    const $buttonGroup = $(buttonGroup);
    $buttonGroup.on('click', 'a', e => {
      $buttonGroup.find('.is-checked').removeClass('is-checked');
      $(e.target).addClass('is-checked');
    });
  });

  if ($('.tags-bar')) {
    const tag = '';
    if (tag !== null && tag !== '') {
      filterForTag(tag);
    }
  }
}
