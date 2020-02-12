# frozen_string_literal: true

# Superclass for all the services that update records
# @author Fletcher91 <thom@argu.co>
class UpdateService < ApplicationService
  # @note Call super when overriding.
  # @param [Hash] attributes The attributes to update the model with
  # @option attributes [Edge, Integer] :parent Virtual attribute for updating the models' parent
  def initialize(resource, attributes: {}, options: {})
    @resource = resource
    update_parent(attributes.delete(:parent))
    super
  end

  private

  def object_attributes=(_obj); end

  def service_action
    :update
  end

  def service_method
    :save!
  end

  def update_parent(parent)
    return unless parent

    resource.parent = parent.is_a?(Edge) ? parent : Edge.find(parent)
  end
end
