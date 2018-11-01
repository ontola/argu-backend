# frozen_string_literal: true

module DataCube
  class ComponentSerializer < BaseSerializer
    has_one :data_set, predicate: NS::CUBE[:dataSet]
    attribute :label, predicate: NS::SCHEMA[:name]
    attribute :description, predicate: NS::SCHEMA[:text]
    attribute :order, predicate: NS::CUBE[:order]
  end
end
