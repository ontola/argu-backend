# frozen_string_literal: true

class ShortnameForm < FormsBase
  fields [
    owner: {sh_class: Edge.iri}
  ]

  class << self
    def referred_resources
      super + [owner: {widget_sequence: :members}]
    end
  end
end
