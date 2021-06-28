# frozen_string_literal: true

module DataCube
  class Measure < Component
    class << self
      def iri
        NS.cube[:MeasureProperty]
      end
    end
  end
end
