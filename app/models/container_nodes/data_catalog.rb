# frozen_string_literal: true

class DataCatalog < ContainerNode
  enhance Datasettable

  self.default_widgets = %i[datasets]

  class << self
    def iri
      [NS::DCAT[:Catalog], NS::ARGU[:ContainerNode]]
    end
  end
end
