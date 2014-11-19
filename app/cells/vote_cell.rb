class VoteCell < Cell::ViewModel

  def show
    render
  end

  private

  def title
    model.voteable.title
  end

  def vote_for
    model.for
  end

  def link_title(&block)
    link_to raw(yield block), url_for(model.voteable)
  end
end