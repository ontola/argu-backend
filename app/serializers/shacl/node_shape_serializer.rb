# frozen_string_literal: true

module SHACL
  class NodeShapeSerializer < ShapeSerializer
    attribute :closed, predicate: NS::SH[:closed]
    attribute :or, predicate: NS::SH[:or]
    attribute :not, predicate: NS::SH[:not]

    has_many :property, predicate: NS::SH[:property]

    def type
      NS::SH[:NodeShape]
    end
  end
end
