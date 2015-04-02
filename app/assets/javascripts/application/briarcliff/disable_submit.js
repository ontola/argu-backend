$(document).on('ready pjax:success', function(){

    $('button:submit').click(function(){
        $('button:submit').addClass("is-loading");
        setTimeout(function(){
            $('button:submit').removeClass("is-loading");
        },2500);
    });

    // Inspired by http://www.alfajango.com/blog/rails-3-remote-links-and-forms/
    // Adds a class to buttons with the class 'remote-link'
    $('.remote-link')
        .bind("ajax:beforeSend", function(evt, xhr, settings){
            var $submitButton = $(this);
            $submitButton.addClass("is-loading");

        })
        .bind('ajax:complete', function(evt, xhr, status){
            var $submitButton = $(this);
            $submitButton.removeClass("is-loading");
        })
        .bind("ajax:error", function(evt, xhr, status, error){

            var $submitButton = $(this);
            $submitButton.removeClass("is-loading");
        });

});