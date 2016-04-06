$("#current-blog-post").html("<%= escape_javascript render(partial: 'phases/phase', locals: local_assigns) %>");
$(".timeline-component .timeline-point, .timeline-component .timeline-phase-title, .timeline-component .timeline-post-title").removeClass('active');
ReactRailsUJS.mountComponents("#current-blog-post");
