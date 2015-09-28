class ActivityListener

  def create_comment_successful(comment)
    a = CreateActivity
            .new(comment.creator,
                 trackable: comment,
                 key: 'comment.create',
                 owner: comment.creator,
                 forum: comment.forum,
                 recipient: comment.commentable)
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
    a.commit
  end
end
