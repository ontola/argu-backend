# frozen_string_literal: true

module ConfirmedDestroyable
  module Model
    extend ActiveSupport::Concern

    included do
      enhance LinkedRails::Enhancements::Destroyable, except: %i[Action]

      attr_accessor :confirmation_string

      before_destroy :validate_confirmation_string

      private

      def validate_confirmation_string
        return if confirmation_string.present? && confirmation_string == I18n.t('destroy_confirm_string')

        errors.add(:confirmation_string, I18n.t('destroy_confirm_error'))

        throw(:abort)
      end
    end

    module ClassMethods
      def confirmation_string
        I18n.t('destroy_confirm_string')
      end
    end
  end
end
