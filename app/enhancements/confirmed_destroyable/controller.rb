# frozen_string_literal: true

module ConfirmedDestroyable
  module Controller
    extend ActiveSupport::Concern

    included do
      include ConfirmedDestroyable::DefaultActions

      has_resource_destroy_action(confirmed_destroy_options)
    end

    private

    def destroy_execute
      return super if permit_params[:confirmation_string] == I18n.t('users_cancel_string')

      current_resource.errors.add(:confirmation_string, I18n.t('errors.messages.should_match'))

      false
    end
  end
end
