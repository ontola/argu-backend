$(document).ready(function() {
    "use strict";
    //Lets the CSS selector know whether javascript is enabled
    document.body.className = document.body.className.replace("no-js","js");

    if (!("ontouchstart" in document.documentElement)) {
        document.documentElement.className += " no-touch";
    }
});