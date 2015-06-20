class QuestionMailer < MailerBase

  def create
    if @thing.forum.present?
      followers = Follow.where(followable_type: 'Forum',
                               followable_id: @thing.forum.id
                       ).where.not(follower_id: @thing.creator.id).includes(follower: :profileable).to_a.collect {|f| f.follower.owner }
    else
      []
    end
  end

end
