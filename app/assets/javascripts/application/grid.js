var container = document.querySelector('.grid');
var masonry = new Masonry(container, {
    columnWidth: '.box-grid-sizer',
    itemSelector: '.box-grid'
});