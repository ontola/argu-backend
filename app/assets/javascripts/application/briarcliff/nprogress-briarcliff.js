$(document).on('pjax:start',   function() { NProgress.start(); });
$(document).on('pjax:success',  function() { NProgress.done(); });
$(document).on('pjax:end', function() { NProgress.remove(); });