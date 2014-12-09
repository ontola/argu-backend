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
        bg.height(_window.height() + 0);
    }
    _window.resize(resizeBackground);
    resizeBackground();

    //Toggle dropdown content when clicked on trigger
    $('.dropdown-trigger').on("tap", function(){
        event.stopPropagation(); //
        $(this).toggleClass("dropdown-active");
    });

    //Hide dropdown content when clicked anywhere
    $(document).on("tap", function(){
        $('.dropdown-trigger').removeClass("dropdown-active");
    });

});