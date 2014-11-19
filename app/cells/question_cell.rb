class QuestionCell < Cell::ViewModel
  def show
    render
  end

private
  property :title
  property :votes_pro_count

  def amount_of_votes
    "#{model.votes_pro_count.to_s} #{I18n.translate("motions.plural")}"
  end

  def content
    model.supped_content.html_safe
  end

  def link_title(&block)
    link_to raw(yield block), question_path(model)
  end

end