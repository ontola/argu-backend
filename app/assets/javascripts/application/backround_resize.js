$(document).ready(function() {
    var bg = $(".background"),
        _window = $(window);
    var resizeBackground = function () {
        bg.height(_window.height() + 0);
    }
    _window.resize(resizeBackground);
    resizeBackground();
});