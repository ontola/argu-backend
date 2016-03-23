# Superclass for all the services that update records
# @author Arthur <arthur@argu.co>
class DestroyService < ApplicationService
  # @note Call super when overriding.
  def initialize(resource, attributes = {}, options = {})
    super
  end

  private

  def service_action
    :destroy
  end
end
