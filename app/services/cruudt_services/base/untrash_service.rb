# frozen_string_literal: true

# Superclass for all the services that trash records
# @author Arthur <arthur@argu.co>
class UntrashService < ApplicationService
  # @note Call super when overriding.
  def initialize(resource, attributes: {}, options: {})
    @resource = resource
    super
  end

  private

  def service_action
    :untrash
  end
end
