# frozen_string_literal: true

module DataCube
  class ComponentSerializer < BaseSerializer
    has_one :data_set, predicate: NS.cube[:dataSet]
    attribute :label, predicate: NS.schema.name
    attribute :description, predicate: NS.schema.text
    attribute :order, predicate: NS.cube[:order]
  end
end
