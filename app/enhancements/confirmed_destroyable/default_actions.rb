# frozen_string_literal: true

module ConfirmedDestroyable
  module DefaultActions
    extend ActiveSupport::Concern

    class_methods do
      private

      def confirmed_destroy_options(overwrite = {})
        {
          form: ConfirmedDestroyForm
        }.merge(overwrite)
      end
    end
  end
end
