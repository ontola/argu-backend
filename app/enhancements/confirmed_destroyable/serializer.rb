# frozen_string_literal: true

module ConfirmedDestroyable
  module Serializer
    extend ActiveSupport::Concern

    included do
      attribute :confirmation_string, predicate: NS::ARGU[:confirmationString], datatype: NS::XSD[:string]
    end
  end
end
