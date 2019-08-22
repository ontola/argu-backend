# frozen_string_literal: true

class Dashboard < ContainerNode
  class << self
    def iri
      NS::SCHEMA[:WebPage]
    end
  end
end
