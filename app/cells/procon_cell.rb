class ProconCell < Cell::ViewModel
  builds do |model, options|
    puts " =============#{model}================="
    StatementCell if model.is_a? Statement
    VoteCell      if model.is_a? Vote
  end

  def show
    render
  end

  def list

  end

  private

  def pro_items
    model['pro']
  end

  def con_items
    model['con']
  end

  def title
    model.title
  end

end