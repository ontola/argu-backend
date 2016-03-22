class ActivityListener
  def create_argument_successful(argument)
    create_activity(argument, argument.motion, 'create')
  end

  def publish_blog_post_successful(blog_post)
    create_activity(blog_post, blog_post.blog_postable, 'publish')
  end

  def create_comment_successful(comment)
    create_activity(comment, comment.subscribable, 'create')
  end

  def create_group_response_successful(group_response)
    create_activity(group_response, group_response.motion, 'create')
  end

  def create_motion_successful(motion)
    recipient = motion.question || motion.forum
    create_activity(motion, recipient, 'create')
  end

  def create_question_successful(question)
    create_activity(question, question.forum, 'create')
  end

  def publish_project_successful(project)
    create_activity(project, project.forum, 'publish')
  end

  private

  def create_activity(resource, recipient, action)
    a = CreateActivity.new(
        resource.creator,
        trackable: resource,
        key: "#{resource.model_name.singular}.#{action}",
        owner: resource.creator,
        forum: resource.forum,
        recipient: recipient)
    a.subscribe(NotificationListener.new)
    a.commit
  end
end
