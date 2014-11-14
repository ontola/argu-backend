class ButtonCell < Cell::ViewModel
  def show
    render
  end

  private
  property :title, :pro, :button, :collection_model, :buttons_url

  def buttons_url
    model[:buttons_url]
  end

  def collection_model
    model[:collection_model]
  end

  def pro
    model[:pro]
  end
end