# frozen_string_literal: true

class CreateMove < CreateService
  def initialize(resource, attributes: {}, options: {})
    @resource = Move.new(edge: resource)
    super
  end

  def broadcast_event; end

  def commit
    ActsAsTenant.with_tenant(ActsAsTenant.without_tenant { resource.new_parent.root }) { super }
  end
end
