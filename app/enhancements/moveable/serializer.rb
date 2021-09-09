# frozen_string_literal: true

module Moveable
  module Serializer
    extend ActiveSupport::Concern

    included do
      secret_attribute :new_parent_id,
                       datatype: NS.xsd.string,
                       predicate: NS.argu[:moveTo]
    end
  end
end
