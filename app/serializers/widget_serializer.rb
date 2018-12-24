# frozen_string_literal: true

class WidgetSerializer < BaseSerializer
  attribute :size, predicate: NS::ARGU[:widgetSize]
  has_one :resource_sequence, predicate: NS::ARGU[:widgetResource]
  has_one :owner, predicate: NS::SCHEMA[:isPartOf]
  has_many :property_shapes

  def property_shapes
    object.property_shapes.values
  end
end
