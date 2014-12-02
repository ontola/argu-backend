$(document).ready(function() {
    "use strict";
    //Lets the CSS selector know whether javascript is enabled
    document.body.className = document.body.className.replace("no-js","js");

    if (!("ontouchstart" in document.documentElement)) {
        document.documentElement.className += " no-touch";
    }
    var bg = $(".background"),
        _window = $(window);
    var resizeBackground = function () {
        bg.height(_window.height() + 160);
    }
    _window.resize(resizeBackground);
    resizeBackground();

});