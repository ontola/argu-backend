# frozen_string_literal: true

class CreateActivity < CreateService
  def initialize(resource, attributes: {}, options: {})
    @resource = resource
    super
  end

  private

  def broadcast_event; end
end
