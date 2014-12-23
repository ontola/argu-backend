//Adds a ".tabs-current" class to tab buttons that direct to the current page

    var str=location.href.toLowerCase();
    $(".tabs li a").each(function() {
        if (str.indexOf(this.href.toLowerCase()) > -1) {
            $("li.tabs-current").removeClass("tabs-current");
            $(this).parent().addClass("tabs-current");
      }
    });
