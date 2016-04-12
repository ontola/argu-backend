# Superclass for all the services that create records
# @author Fletcher91 <thom@argu.co>
class CreateService < ApplicationService
  # @note Call super when overriding.
  def initialize(resource, attributes = {}, options = {})
    super
  end

  private

  def after_save
    create_publication if resource.respond_to?(:publish_at)
    resource.publisher.follow(resource) if resource.try(:publisher).present?
  end

  def service_action
    :create
  end

  def service_method
    :save!
  end

  def set_object_attributes(obj)
    raise 'Required interface not implemented'
  end
end
