# frozen_string_literal: true

class ShortnameForm < RailsLD::Form
  fields [
    owner: {sh_class: Edge.iri}
  ]

  class << self
    def referred_resources
      super + [owner: {widget_sequence: {members: %i[resource_sequence property_shapes]}}]
    end
  end
end
