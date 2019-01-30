# frozen_string_literal: true

class ShortnameForm < RailsLD::Form
  fields [
    owner: {sh_class: Edge.iri}
  ]
end
