$(function() {
    var _document = $(document);

    _document.on('focus', '.dropdown', function (e) {
        var _this = $(this),
            isActive = _this.hasClass('dropdown-active');
        _document.find('.dropdown').removeClass('dropdown-active');
        _this.toggleClass('dropdown-active', !isActive);
    }).focusout(function (e) {
        $(e.target).removeClass('dropdown-active');
    });

    _document.on("tap click", '.dropdown div:first', function (e) {
        // Prevents dropdown-active from opening the neighboring link in Chrome for android.. but also prevents clicking on dropdown content!
        e.preventDefault();
    });
});