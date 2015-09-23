class ActivityListener

  def create_comment_successful(comment)
    c = CreateActivity
            .new(comment.creator,
                 trackable: comment,
                 key: 'comment.create',
                 owner: comment.creator,
                 forum: comment.forum,
                 recipient: comment.commentable)
    c.commit
  end
end
