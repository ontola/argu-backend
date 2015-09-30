class ActivityListener

  def create_argument_successful(argument)
    a = CreateActivity
            .new(argument.creator,
                 trackable: argument,
                 key: 'argument.create',
                 owner: argument.creator,
                 forum: argument.forum,
                 recipient: argument.motion)
    a.subscribe(NotificationListener.new)
    a.commit
  end

  def create_comment_successful(comment)
    a = CreateActivity
            .new(comment.creator,
                 trackable: comment,
                 key: 'comment.create',
                 owner: comment.creator,
                 forum: comment.forum,
                 recipient: comment.subscribable)
    a.subscribe(NotificationListener.new)
    a.commit
  end

  def create_motion_successful(motion)
    recipient = motion.questions.present? ? motion.questions.first : motion.forum
    a = CreateActivity
            .new(motion.creator,
                 trackable: motion,
                 key: 'motion.create',
                 owner: motion.creator,
                 forum: motion.forum,
                 recipient: recipient)
    a.subscribe(NotificationListener.new)
    a.commit
  end

  def create_question_successful(question)
    a = CreateActivity
            .new(question.creator,
                 trackable: question,
                 key: 'question.create',
                 owner: question.creator,
                 forum: question.forum,
                 recipient: question.forum)
    a.subscribe(NotificationListener.new)
    a.commit
  end
end
