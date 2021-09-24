# frozen_string_literal: true

module Transferable
  module Serializer
    extend ActiveSupport::Concern

    included do
      attribute :transfer_to, datatype: NS.xsd.string, predicate: NS.argu[:transferTo]
    end
  end
end
