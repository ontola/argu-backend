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

     $('.collapsible').each(function(i, e) {
         var span   = $(this).find('span').toggle(),
             before = $('<span>...<a href="#">meer</a></span>'),
             after  = $('<span><a href="#">minder</a></span>').hide(),
           _onclick = function test (e) {e.preventDefault(); before.toggle(); span.toggle(); after.toggle(); };
         span.before(before.click(_onclick));
         span.after(after.click(_onclick));
     });

     $('.form-toggle input[type="radio"]').change(function() {
         var tmp=$(this).attr('name'),
             _this = $(this);
         $('input[name="'+tmp+'"]').parent("label").removeClass("checked");
         _this.parent("label").toggleClass("checked", this.selected);
         window.argblaat = _this;
         $(':not(.formtastic).argument').removeClass('side-pro side-con').addClass('side-' + _this.attr('value'));
     });
 });