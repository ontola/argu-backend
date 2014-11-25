class ButtonCell < Cell::ViewModel
  include ApplicationHelper

  def show
    render
  end

  private
  property :title, :pro, :button, :collection_model, :buttons_url

  def buttons_url
    merge_query_parameter(model[:buttons_url], {pro: model[:pro]})
  end

  def collection_model
    model[:collection_model]
  end

  def pro
    model[:pro]
  end
end