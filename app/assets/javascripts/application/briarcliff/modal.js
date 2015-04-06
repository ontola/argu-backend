$(function () {
    "use strict";

    // Close modal when clicking on overlay, unless there is a "no-close" class.
    $(document).on('click', '.modal-container:not(.no-close) .overlay', function () {
        var container = $(this).parent('.modal-container');

        container.addClass('modal-hide');
        window.setTimeout(function () {
            container.remove();
            $('body').removeClass('modal-opened');
        }, 500);
    });

    // Close modal when pressing escape button, unless there is a "no-close" class.
    document.addEventListener('keyup', function(e) {
        if (e.keyCode == 27 && !$(".no-close")[0]) {
            $('.modal-container').addClass('modal-hide');
            window.setTimeout(function () {
                $('.modal-container').remove();
                $('body').removeClass('modal-opened');
            }, 500);
        }
    });

    $(document).on('pjax:complete', function () {
        $('body').removeClass('modal-opened');
    });
});