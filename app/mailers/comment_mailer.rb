class CommentMailer < MailerBase

  def create
    if @thing.present?
      if @thing.parent.present?
        _id, _type = @thing.parent.id, 'Comment'
      else
        _id, _type = @thing.commentable_id, @thing.commentable_type
      end
      followers = Follow.where(followable_type: _type,
                               followable_id: _id
      ).where.not(follower_id: @thing.creator.id).includes(follower: :profileable).to_a.collect {|f| f.follower.owner }
    else
      []
    end
  end

end