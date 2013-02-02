 $(document).ready(function() {
    $('#expand').css("height", "2.5em");

    $('#expand').click(function() {
        var reducedHeight = $(this).height();
        $(this).css('height', 'auto');
        var fullHeight = $(this).height();
        $(this).height(reducedHeight);
        var newHeight = $(this).height() == fullHeight ? "2.5em" : fullHeight;
        $(this).animate({height: newHeight}, 500);
    });

 });