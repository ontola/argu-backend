# frozen_string_literal: true

module SHACL
  class PropertyGroupSerializer < BaseSerializer
    attribute :label, predicate: NS::RDFS[:label]
    attribute :order, predicate: NS::SH[:order]

    def type
      NS::SH[:PropertyGroup]
    end
  end
end
