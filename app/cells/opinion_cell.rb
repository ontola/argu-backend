class OpinionCell < Cell::ViewModel
  def show
    render
  end

  private
  property :title, :pro, :supped_content, :comment_threads, :votes_pro_count, :id, :comments_count

  def link_title(&block)
    link_to raw(yield block), question_path(model)
  end

  def supped_content
    ((content = model.supped_content)[0..500] + (content_tag(:span, content[501..content.length].to_s) if content[501]).to_s)
  end

  def vote_buttons
    render partial: "opinions/shr", locals: { opinion: model }
  end
end