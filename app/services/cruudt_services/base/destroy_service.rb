# frozen_string_literal: true

# Superclass for all the services that destroy records
# @author Arthur <arthur@argu.co>
class DestroyService < ApplicationService
  # @note Call super when overriding.
  def initialize(resource, attributes: {}, options: {})
    @resource = resource
    if confirmation_string && options[:confirmation_string] != confirmation_string
      @resource.errors.add(:confirmation_string, I18n.t('errors.messages.should_match'))
    end
    super
  end

  private

  def confirmation_string; end

  def service_action
    :destroy
  end
end
