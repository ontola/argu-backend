# frozen_string_literal: true

class CreateConversion < CreateService
  def initialize(resource, attributes: {}, options: {})
    @resource = resource
    attributes[:klass] = attributes[:klass].classify.constantize if attributes[:klass].is_a?(String)
    super
  end

  def broadcast_event; end
end
