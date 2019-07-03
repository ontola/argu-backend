# frozen_string_literal: true

class UpdateArgument < EdgeableUpdateService
  private

  def assign_attributes
    super
    klass = resource.pro ? ProArgument : ConArgument
    @resource = resource.becomes!(klass) unless resource.is_a?(klass)
  end

  def object_attributes=(obj)
    obj.creator ||= resource.creator if obj.respond_to?(:creator)
  end
end
