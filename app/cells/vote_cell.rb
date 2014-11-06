class VoteCell < Cell::ViewModel

  def show
    render
  end

  private

  def title
    model.voteable.title
  end
end