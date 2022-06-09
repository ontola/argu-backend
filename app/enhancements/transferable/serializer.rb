# frozen_string_literal: true

module Transferable
  module Serializer
    extend ActiveSupport::Concern

    included do
      attribute :transfer_to, datatype: NS.xsd.string, predicate: NS.argu[:transferTo]
      enum :transfer_type, predicate: NS.argu[:transferType]
    end
  end
end
