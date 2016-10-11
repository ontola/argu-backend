# frozen_string_literal: true

# Superclass for all the services that create records
# @author Fletcher91 <thom@argu.co>
class CreateService < ApplicationService
  # @note Call super when overriding.
  def initialize(resource, attributes: {}, options: {})
    super
  end

  private

  def resource_klass
    self.class.to_s.gsub('Create', '').constantize
  end

  def service_action
    :create
  end

  def service_method
    :save!
  end

  def object_attributes=(_obj)
    raise 'Required interface not implemented'
  end
end
