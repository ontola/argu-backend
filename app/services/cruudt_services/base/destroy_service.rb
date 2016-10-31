# frozen_string_literal: true
# Superclass for all the services that destroy records
# @author Arthur <arthur@argu.co>
class DestroyService < ApplicationService
  # @note Call super when overriding.
  def initialize(resource, attributes: {}, options: {})
    @resource = resource
    super
  end

  private

  def service_action
    :destroy
  end
end
