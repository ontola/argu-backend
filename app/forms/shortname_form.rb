# frozen_string_literal: true

class ShortnameForm < ApplicationForm
  fields [
    owner: {sh_class: Edge.iri}
  ]
end
