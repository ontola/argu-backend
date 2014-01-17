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

    $('.c_reply').click(function(event) {
    	event.preventDefault();
    	$('.comment_form#cf' + $(this).attr('id')).slideDown();
    });

     $('.collapsible').each(function(i, e) {
         var span = $(this).find('span');
         var before = $('<span>...<a href="#">meer</a></span>');
         var after = $('<span><a href="#">minder</a></span>');
         var _onclick = function(e) {
             if(e!=undefined) e.preventDefault();
             span.toggle();
             before.toggle();
             after.toggle();
         }();
         span.after(after);
         span.before(before);
         after.toggle();
         before.click(function (e) {e.preventDefault(); $(this).toggle(); span.toggle(); after.toggle(); });
         after.click(function (e) {e.preventDefault(); $(this).toggle(); span.toggle(); before.toggle(); });
     });

 });