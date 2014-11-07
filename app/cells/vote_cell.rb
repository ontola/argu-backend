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
end