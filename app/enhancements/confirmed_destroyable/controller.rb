# frozen_string_literal: true

module ConfirmedDestroyable
  module Controller
    extend ActiveSupport::Concern

    private

    def destroy_execute
      return super if permit_params[:confirmation_string] == I18n.t('users_cancel_string')

      current_resource.errors.add(:confirmation_string, I18n.t('errors.messages.should_match'))

      false
    end
  end
end
