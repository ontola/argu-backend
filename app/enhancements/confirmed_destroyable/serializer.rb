# frozen_string_literal: true

module ConfirmedDestroyable
  module Serializer
    extend ActiveSupport::Concern

    included do
      attribute :confirmation_string,
                predicate: NS.argu[:confirmationString],
                datatype: NS.xsd.string
    end
  end
end
