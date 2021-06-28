# frozen_string_literal: true

module DataCube
  class Dimension < Component
    class << self
      def iri
        NS.cube[:DimensionProperty]
      end
    end
  end
end
