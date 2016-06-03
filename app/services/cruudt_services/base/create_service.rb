# Superclass for all the services that create records
# @author Fletcher91 <thom@argu.co>
class CreateService < ApplicationService
  # @note Call super when overriding.
  def initialize(resource, attributes = {}, options = {})
    super
  end

  private

  def service_action
    :create
  end

  def service_method
    :save!
  end

  def object_attributes=(obj)
    raise 'Required interface not implemented'
  end
end
