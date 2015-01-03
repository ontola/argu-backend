$(function() {
    //Toggle dropdown content when clicked on trigger
    $('.dropdown-trigger').on("tap click", function (e){
        // Prevents opening the neighboring link in Chrome for android
        e.preventDefault(); //
        $(this).toggleClass("dropdown-active");
    });

    //Hide dropdown content when clicked anywhere
    $(document).on("tap click", function(){
        $('.dropdown-trigger').removeClass("dropdown-active");
    });
});