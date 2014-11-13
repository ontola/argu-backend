class FeedCell < Cell::ViewModel
  builds do |model, options|
    #StatementCell   if model.is_a? Statement
    QuestionCell    if model.is_a? Question
  end

  def show

  end


end