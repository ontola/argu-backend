# frozen_string_literal: true

class WidgetSerializer < BaseSerializer
  attribute :resource_iri, predicate: NS::SCHEMA[:url]
  attribute :label, predicate: NS::SCHEMA[:name]
  attribute :body, predicate: NS::SCHEMA[:text]
  attribute :size, predicate: NS::ARGU[:widgetSize]

  has_one :owner, predicate: NS::SCHEMA[:isPartOf]
end
