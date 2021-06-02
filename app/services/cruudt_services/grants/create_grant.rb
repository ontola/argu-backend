# frozen_string_literal: true

class CreateGrant < CreateService
  def initialize(parent, attributes: {}, options: {})
    child_parent = parent || ActsAsTenant.current_tenant
    @resource = child_parent&.build_child(Grant, user_context: options[:user_context]) || Grant.build_new
    super
  end

  private

  def object_attributes=; end
end
