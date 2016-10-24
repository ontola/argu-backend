# frozen_string_literal: true
# Service for destroying grants.
class DestroyGrant < DestroyService
  include Wisper::Publisher

  def initialize(resource, attributes: {}, options: {})
    @resource = resource
    super
  end

  attr_reader :resource
end
