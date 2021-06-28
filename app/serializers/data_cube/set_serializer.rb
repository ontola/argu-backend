# frozen_string_literal: true

module DataCube
  class SetSerializer < BaseSerializer
    attribute :label, predicate: NS.schema.name
    attribute :description, predicate: NS.schema.text

    has_one :parent, predicate: NS.schema.isPartOf, polymorphic: true
    has_one :data_structure, predicate: NS.cube[:structure], polymorphic: true
    has_many :observations, predicate: NS.cube[:observation], polymorphic: true
  end
end
