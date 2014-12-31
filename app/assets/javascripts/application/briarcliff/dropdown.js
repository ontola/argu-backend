$(function() {
    //Toggle dropdown content when clicked on trigger
    $('.dropdown-trigger').on("tap click", function (e){
        e.preventDefault(); //
        $(this).toggleClass("dropdown-active");
    });

    //Hide dropdown content when clicked anywhere
    $(document).on("tap click", function(){
        $('.dropdown-trigger').removeClass("dropdown-active");
    });
});