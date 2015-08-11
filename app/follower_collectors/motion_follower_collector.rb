class MotionFollowerCollector < FollowerCollectorBase

  def create
    if @thing.questions.present?
      followers = Follow.where(followable_type: 'Question',
                               followable_id: @thing.questions.pluck(:id)
                       ).where.not(follower_id: @thing.creator.id).includes(follower: :profileable).to_a.collect {|f| f.follower.owner }
    else
      []
    end
  end

end
