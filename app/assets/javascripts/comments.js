$(function() {
    $('.comment .btn-reply').click(function(event) {
        event.preventDefault();
        $('.comment_form#cf' + $(this).attr('id')).slideToggle();
    });
});