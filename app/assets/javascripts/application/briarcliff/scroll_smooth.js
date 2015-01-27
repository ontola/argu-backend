$(document).ready(function() {
    //scroll to item. Used in landing page.
    $(function() {
        $('a[href*=#]:not([href=#])').click(function() {
            if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') && location.hostname == this.hostname) {
                var target = $(this.hash);
                target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
                if (target.length) {
                    history.pushState(null, null, '#' + this.hash.slice(1));
                    $('html,body').animate({
                        scrollTop: target.offset().top - 200
                    }, 600);
                    return false;
                }
            }
        });
    });
});