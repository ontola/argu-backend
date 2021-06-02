# frozen_string_literal: true

class CreateConversion < CreateService
  def initialize(resource, attributes: {}, options: {})
    @resource = Conversion.new(edge: resource)
    super
  end

  def broadcast_event; end
end
