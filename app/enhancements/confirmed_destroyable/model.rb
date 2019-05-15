# frozen_string_literal: true

module ConfirmedDestroyable
  module Model
    extend ActiveSupport::Concern

    included do
      enhance LinkedRails::Enhancements::Destroyable, except: %i[Action]

      attr_accessor :confirmation_string

      validates :confirmation_string,
                format: {with: ->(_r) { /\A#{I18n.t('destroy_confirm_string')}\z/ }, on: :destroy}
    end

    module ClassMethods
      def confirmation_string
        I18n.t('destroy_confirm_string')
      end
    end
  end
end
