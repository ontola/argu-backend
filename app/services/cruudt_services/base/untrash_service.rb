# frozen_string_literal: true
# Superclass for all the services that trash records
# @author Arthur <arthur@argu.co>
class UntrashService < ApplicationService
  include Wisper::Publisher

  # @note Call super when overriding.
  def initialize(resource, attributes: {}, options: {})
    @resource = resource
    super
  end
  attr_reader :resource

  private

  def service_action
    :untrash
  end
end
