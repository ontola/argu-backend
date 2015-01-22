$(function() {
    $(document).on('click', '.comment .btn-reply', function(event) {
        event.preventDefault();
        $('.comment_form#cf' + $(this).attr('id')).slideToggle();
    });
});