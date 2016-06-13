$("#current-blog-post").html("<%= escape_javascript render(partial: 'blog_posts/timeline', locals: {blog_post: blog_post}) %>");
$(".timeline-component .timeline-point, .timeline-component .timeline-phase-title, .timeline-component .timeline-post-title").removeClass('active');
ReactRailsUJS.mountComponents("#current-blog-post");
