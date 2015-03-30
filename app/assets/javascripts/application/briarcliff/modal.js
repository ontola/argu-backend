$(function () {
    "use strict";

    // Close modal when clicking on overlay, unless there is a "no-close" class.
    $(document).on('click', '.modal-container:not(.no-close) .overlay', function () {
        var container = $(this).parent('.modal-container');

        container.addClass('modal-hide');
        window.setTimeout(function () {
            container.remove();
        }, 500);
    });

    // Close modal when pressing escape button, unless there is a "no-close" class.
    document.addEventListener('keyup', function(e) {
        if (e.keyCode == 27 && !$(".no-close")[0]) {
            $('.modal-container').addClass('modal-hide');
            window.setTimeout(function () {
                $('.modal-container').remove();
            }, 500);
        }
    });

    // TODO: add '.modal-open' to body upon opening a modal to disable background scrolling

});