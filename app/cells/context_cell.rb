class ContextCell < Cell::ViewModel
  extend ViewModel
  def to_parent
    render if get_parent.present?
  end

  private

  def get_parent
    model.get_parent(params)
  end

  def parent
    get_parent.model
  end

  def parent_path
    get_parent.url
  end

  def parent_title
    parent.display_name
  end

  def parent_type
    parent.class.to_s.downcase
  end
end