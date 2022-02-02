# frozen_string_literal: true

module DataCube
  class SetSerializer < BaseSerializer
    attribute :label, predicate: NS.schema.name
    attribute :description, predicate: NS.schema.text

    has_one :parent, predicate: NS.schema.isPartOf
    has_one :data_structure, predicate: NS.cube[:structure]
    has_many :observations, predicate: NS.cube[:observation]
  end
end
