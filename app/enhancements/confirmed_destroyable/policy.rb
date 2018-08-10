# frozen_string_literal: true

module ConfirmedDestroyable
  module Policy
    extend ActiveSupport::Concern

    def permitted_attribute_names
      attributes = super
      attributes.append(:confirmation_string)
      attributes
    end
  end
end
