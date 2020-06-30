# frozen_string_literal: true

module ConfirmedDestroyable
  module Policy
    extend ActiveSupport::Concern

    included do
      permit_attributes %i[confirmation_string]
    end
  end
end
