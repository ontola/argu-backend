# frozen_string_literal: true
# Superclass for all the services that trash records
# @author Arthur <arthur@argu.co>
class TrashService < ApplicationService
  # @note Call super when overriding.
  def initialize(resource, attributes: {}, options: {})
    super
  end

  private

  def service_action
    :trash
  end
end
