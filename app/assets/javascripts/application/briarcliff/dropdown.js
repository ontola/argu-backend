$(function() {
    $(document).on("tap click", '.dropdown div:first', function (e) {
        // Prevents dropdown-active from opening the neighboring link in Chrome for android.. but also prevents clicking on dropdown content!
        e.preventDefault();
    });
});