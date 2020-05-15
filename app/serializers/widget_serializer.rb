# frozen_string_literal: true

class WidgetSerializer < LinkedRails::WidgetSerializer
  attribute :position, predicate: NS::ARGU[:order]
  attribute :raw_resource_iri, predicate: NS::ARGU[:rawResource], datatype: NS::XSD[:string]
  attribute :topology, predicate: NS::ONTOLA[:topology]

  enum :view, predicate: NS::ARGU[:view]
end
