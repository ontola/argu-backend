$(function () {
    "use strict";
    $(document).on('click', '.modal-container .overlay:not(.no-close)', function () {
        var container = $(this).parent('.modal-container');

        container.addClass('modal-hide');
        window.setTimeout(function () {
            container.remove();
        }, 500);
    });

});