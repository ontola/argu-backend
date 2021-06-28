# frozen_string_literal: true

class Dashboard < ContainerNode
  class << self
    def iri
      NS.schema[:WebPage]
    end
  end
end
