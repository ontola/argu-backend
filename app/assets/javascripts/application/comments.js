$(function() {
    $(document).on('click', '.comment .btn-reply', function(e) {
        e.preventDefault();
        $('.comment_form#cf' + $(this).attr('id')).slideToggle();
    });
});