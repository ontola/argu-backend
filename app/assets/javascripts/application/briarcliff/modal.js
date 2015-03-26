$(function () {
    "use strict";

    function modalClose (){
        var container = $(this).parent('.modal-container');

        container.addClass('modal-hide');
        window.setTimeout(function () {
            container.remove();
        }, 500);
    }

    document.addEventListener('keyup', function(e) {
        if (e.keyCode == 27) {
            modalClose();
        }
    });

    $(document).on('click', '.modal-container .overlay:not(.no-close)', function () {
        var container = $(this).parent('.modal-container');

        container.addClass('modal-hide');
        window.setTimeout(function () {
            container.remove();
        }, 500);
    });

});