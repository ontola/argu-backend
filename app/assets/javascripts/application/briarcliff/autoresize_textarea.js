// http://stackoverflow.com/a/25621277/2502163
// TODO: Initialize when page is loaded

$(document).ready(function() {
    $(document).on('pjax:success', function() {
        function h(e) {
            $(e).css({'height':'auto','overflow-y':'hidden'}).height(e.scrollHeight);
        }
        $('textarea').each(function () {
            h(this);
        }).on('input', function () {
            h(this);
        });
    });
});