//mmenu initiate
$(document).ready(function() {
    $("#nav-side").mmenu({
        // options
    }, {
        // configuration
        clone: true
    });

    $("#nav-side").mmenu();
    $("#nav-menu-btn").click(function() {
        $("#mm-nav-side").trigger("open.mm");
    });
});