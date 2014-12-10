$(document).ready(function() {
    //Toggle dropdown content when clicked on trigger
    $('.dropdown-trigger').on("tap", function(){
        event.stopPropagation(); //
        $(this).toggleClass("dropdown-active");
    });

    //Hide dropdown content when clicked anywhere
    $(document).on("tap", function(){
        $('.dropdown-trigger').removeClass("dropdown-active");
    });
});