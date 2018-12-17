# frozen_string_literal: true

class CreateMove < CreateService
  def initialize(resource, attributes: {}, options: {})
    @resource = Move.new(edge: resource)
    super
  end

  def broadcast_event; end
end
