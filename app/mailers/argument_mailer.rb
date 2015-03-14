class ArgumentMailer < MailerBase

  def create
    if @thing.motion.present?
      followers = Follow.where(followable_type: 'Motion',
                               followable_id: @thing.motion.id
      ).where.not(follower_id: @thing.creator.id).includes(follower: :profileable).to_a.collect {|f| f.follower.owner }
    else
      []
    end
  end
end