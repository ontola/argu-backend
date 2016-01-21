class ActivityListener

  def create_argument_successful(argument)
    a = CreateActivity.new(
      argument.creator,
      trackable: argument,
      key: 'argument.create',
      owner: argument.creator,
      forum: argument.forum,
      recipient: argument.motion)
    a.subscribe(NotificationListener.new)
    a.commit
  end

  def publish_blog_post_successful(blog_post)
    a = CreateActivity.new(
      argument.creator,
      trackable: blog_post,
      key: 'blog_post.publish',
      owner: blog_post.creator,
      forum: blog_post.forum,
      recipient: blog_post.blog_postable)
    fdsa
    a.commit
  end

  def create_comment_successful(comment)
    a = CreateActivity.new(
      comment.creator,
      trackable: comment,
      key: 'comment.create',
      owner: comment.creator,
      forum: comment.forum,
      recipient: comment.subscribable)
    a.subscribe(NotificationListener.new)
    a.commit
  end

  def create_motion_successful(motion)
    recipient = motion.question || motion.forum
    a = CreateActivity.new(
      motion.creator,
      trackable: motion,
      key: 'motion.create',
      owner: motion.creator,
      forum: motion.forum,
      recipient: recipient)
    a.subscribe(NotificationListener.new)
    a.commit
  end

  def create_question_successful(question)
    a = CreateActivity.new(
      question.creator,
      trackable: question,
      key: 'question.create',
      owner: question.creator,
      forum: question.forum,
      recipient: question.forum)
    a.subscribe(NotificationListener.new)
    a.commit
  end

  def publish_project_successful(project)
    a = CreateActivity.new(
      project.creator,
      trackable: project,
      key: 'project.publish',
      owner: project.creator,
      forum: project.forum,
      recipient: project.forum)
    a.subscribe(NotificationListener.new)
    a.commit
  end
end
