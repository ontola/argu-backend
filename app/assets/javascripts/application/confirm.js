$(function () {
    "use strict";
    $(document).on('keyup', '.confirm .confirm-text', function () {
        var _this = $(this);
        _this.closest('.confirm').find('.confirm-action').attr('disabled', _this.val() != _this.attr('confirm-text'));
    });
});