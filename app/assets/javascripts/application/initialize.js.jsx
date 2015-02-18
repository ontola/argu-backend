$(function (){
    "use strict";

    //Lets the CSS selector know whether javascript is enabled
    document.body.className = document.body.className.replace("no-js","js");

    $.pjax.defaults.timeout = 5000;
    $(document).pjax('a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])', '#pjax-container');

    /*React.render(
        <Navbar />,
        document.getElementById('navbar')
    );*/

    if (!("ontouchstart" in document.documentElement)) {
        document.documentElement.className += " no-touch";
    }
});