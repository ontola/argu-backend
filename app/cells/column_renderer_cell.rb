class ColumnRendererCell < Cell::ViewModel
  builds do |model, options|
    if model.is_a?(Statement)
      StatementCell
    elsif model.is_a?(Argument)
      ArgumentCell
    elsif model.is_a?(Vote)
      VoteCell
    end
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