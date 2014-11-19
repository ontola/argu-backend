class FeedCell < Cell::ViewModel
  builds do |model, options|
    #MotionCell   if model.is_a? Motion
    QuestionCell    if model.is_a? Question
  end

  def show

  end


end