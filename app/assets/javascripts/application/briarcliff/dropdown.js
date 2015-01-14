$(function() {
    //Do this on pageload
    var _dropdown = $('.dropdown');

    //Toggle dropdown content when clicked on trigger
    _dropdown.on("tap click", function (e){
        // Prevents dropdown-active from opening the neighboring link in Chrome for android.. but also prevents clicking on dropdown content!
        //e.preventDefault();

        $(this).toggleClass("dropdown-active");
    });

    //Remove dropdown content when clicked anywhere else
    $('body').on("tap click", function(event){
        _dropdown.not(_dropdown.has(event.target)).removeClass("dropdown-active");
    });
});