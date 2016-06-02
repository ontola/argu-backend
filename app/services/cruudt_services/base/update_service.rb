# Superclass for all the services that update records
# @author Fletcher91 <thom@argu.co>
class UpdateService < ApplicationService
  # @note Call super when overriding.
  def initialize(resource, attributes = {}, options = {})
    super
  end

  private

  def service_action
    :update
  end

  def service_method
    :save!
  end
end
