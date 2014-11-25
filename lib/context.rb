class Context
  include Rails.application.routes.url_helpers

  attr_accessor :model
  attr_reader :url

  def initialize(model = nil)
    model = model
  end

  def model=(value)
    @model = value
    @url = url_for(controller: @model.class.name.downcase.pluralize.to_sym, action: :show, id: @model.id, only_path: true) if value
  end

  # Returns true if a model is loaded, otherwise it returns false
  def present?
    model.present?
  end
end
