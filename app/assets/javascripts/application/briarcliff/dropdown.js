$(function() {
    var _document = $(document);

    _document.on('focus', '.dropdown', function (e) {
        console.log('focus');
        var _this = $(this),
            isActive = _this.hasClass('dropdown-active');
        _document.find('.dropdown').removeClass('dropdown-active');
        _this.toggleClass('dropdown-active', !isActive);
    }).focusout(function (e) {
        window._e = e;
        window._this = this;
        $(e.target).removeClass('dropdown-active');
        console.log('focusout');
    });

    _document.on("tap click", '.dropdown div:first', function (e) {
        // Prevents dropdown-active from opening the neighboring link in Chrome for android.. but also prevents clicking on dropdown content!
        e.preventDefault();
    });
});