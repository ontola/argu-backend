# frozen_string_literal: true

class UpdateArgument < UpdateEdge
  private

  def assign_attributes
    super
    klass = resource.pro ? ProArgument : ConArgument
    @resource = resource.becomes!(klass) unless resource.is_a?(klass)
  end
end
