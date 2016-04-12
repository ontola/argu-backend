# Superclass for all the services that update records
# @author Fletcher91 <thom@argu.co>
class UpdateService < ApplicationService
  # @note Call super when overriding.
  def initialize(resource, attributes = {}, options = {})
    super
  end

  private

  def after_save
    if @attributes[:publish_type].present?
      if resource.argu_publication.present?
        resource.argu_publication.update(published_at: resource.publish_at)
      else
        create_publication
      end
    end
  end

  def service_action
    :update
  end

  def service_method
    :save!
  end
end
