$(function () {
    "use strict";

    //Close modal when clicking on overlay
    $(document).on('click', '.modal-container:not(.no-close) .overlay', function () {
        var container = $(this).parent('.modal-container');

        container.addClass('modal-hide');
        window.setTimeout(function () {
            container.remove();
        }, 500);
    });

    //Close modal when pressing escape button
    document.addEventListener('keyup', function(e) {
        if (e.keyCode == 27) {
            $('.modal-container').addClass('modal-hide');
            window.setTimeout(function () {
                $('.modal-container').remove();
            }, 500);
        }
    });

});