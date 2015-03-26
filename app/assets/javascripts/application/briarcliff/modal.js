$(function () {
    "use strict";

    $(document).on('click', '.modal-container .overlay:not(.no-close)', function () {
        var container = $(this).parent('.modal-container');

        container.addClass('modal-hide');
        window.setTimeout(function () {
            container.remove();
        }, 500);
    });

    document.addEventListener('keyup', function(e) {
        if (e.keyCode == 27) {
            $('.modal-container').addClass('modal-hide');
            window.setTimeout(function () {
                $('.modal-container').remove();
            }, 500);
        }
    });

});