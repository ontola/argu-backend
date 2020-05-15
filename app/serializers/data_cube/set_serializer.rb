# frozen_string_literal: true

module DataCube
  class SetSerializer < BaseSerializer
    attribute :label, predicate: NS::SCHEMA[:name]
    attribute :description, predicate: NS::SCHEMA[:text]

    has_one :parent, predicate: NS::SCHEMA[:isPartOf], polymorphic: true
    has_one :data_structure, predicate: NS::CUBE[:structure], polymorphic: true
    has_many :observations, predicate: NS::CUBE[:observation], polymorphic: true
  end
end
