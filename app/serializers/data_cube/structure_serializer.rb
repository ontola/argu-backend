# frozen_string_literal: true

module DataCube
  class StructureSerializer < BaseSerializer
    has_many :measures, predicate: NS.cube[:component]
    has_many :dimensions, predicate: NS.cube[:component]
  end
end
