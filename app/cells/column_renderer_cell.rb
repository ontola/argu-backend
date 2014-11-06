class ColumnRendererCell < Cell::ViewModel
  builds do |model, options|
    StatementCell if model.is_a? Statement
    VoteCell      if model.is_a? Vote
  end

  def show
    render
  end

  private

  def header
    options[:header]
  end

  def keys
    model.keys
  end

  def title
    model.title
  end

end