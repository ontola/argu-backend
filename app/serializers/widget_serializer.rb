# frozen_string_literal: true

class WidgetSerializer < LinkedRails::WidgetSerializer
  attribute :position, predicate: NS.argu[:order]
  attribute :raw_resource_iri, predicate: NS.argu[:rawResource], datatype: NS.xsd.string
  attribute :topology, predicate: NS.ontola[:topology]

  enum :view, predicate: NS.argu[:view]
end
