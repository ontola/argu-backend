$(document).on('pjax:start',   function() { NProgress.start(); });
$(document).on('pjax:success',  function() { NProgress.done(); });
$(document).on('pjax:end', function() { NProgress.remove(); });

$(document).on('ajax:beforeSend',   function() { NProgress.start(); });
$(document).on('ajax:complete',  function() { NProgress.done(); });
$(document).on('ajax:after', function() { NProgress.remove(); });