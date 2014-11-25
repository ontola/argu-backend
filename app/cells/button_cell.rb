class ButtonCell < Cell::ViewModel
  include ApplicationHelper

  def show
    render
  end

  private
  property :title, :pro, :button, :collection_model, :buttons_url

  def buttons_url
    if model[:buttons_param].present?
      merge_query_parameter(model[:buttons_url], {model[:buttons_param] => model[:pro]})
    else
      model[:buttons_url]
    end
  end

  def collection_model
    model[:collection_model]
  end

  def pro
    model[:pro]
  end
end