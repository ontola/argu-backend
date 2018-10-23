# frozen_string_literal: true

module DataCube
  class SetSerializer < BaseSerializer
    attribute :label, predicate: NS::SCHEMA[:name]
    attribute :description, predicate: NS::SCHEMA[:text]

    has_one :data_structure, predicate: NS::CUBE[:structure]
    has_many :observations
  end
end