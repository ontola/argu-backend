# frozen_string_literal: true

module DataCube
  class StructureSerializer < BaseSerializer
    has_many :measures, predicate: NS::CUBE[:component], polymorphic: true
    has_many :dimensions, predicate: NS::CUBE[:component], polymorphic: true
  end
end
