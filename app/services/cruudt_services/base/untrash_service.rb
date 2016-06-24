# Superclass for all the services that trash records
# @author Arthur <arthur@argu.co>
class UntrashService < ApplicationService
  # @note Call super when overriding.
  def initialize(resource, attributes: {}, options: {})
    super
  end

  private

  def service_action
    :untrash
  end
end
