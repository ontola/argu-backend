class ContextCell < Cell::ViewModel
  extend ViewModel
  def to_parent
    render
  end

  private
  property :get_parent

  def parent_path
    url_for controller: get_parent.class.name.downcase.pluralize.to_sym, action: :show, id: get_parent.id
  end

  def parent_title
    get_parent.display_name
  end

  def parent_type
    get_parent.class.to_s.downcase
  end
end