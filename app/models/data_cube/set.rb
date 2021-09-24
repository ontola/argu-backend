# frozen_string_literal: true

module DataCube
  class Set < LinkedRails::Resource
    attr_accessor :description, :dimensions, :label, :measures, :observations, :parent

    def initialize(**opts)
      super
      observations.map! do |observation|
        Observation.new(
          data_set: self,
          dimensions: observation[:dimensions].transform_keys { |key| dimension_by_predicate(key) },
          measures: observation[:measures].transform_keys { |key| measure_by_predicate(key) }
        )
      end
    end

    def data_structure
      @data_structure ||= Structure.new(data_set: self)
    end

    private

    def dimension_by_predicate(predicate)
      data_structure.dimensions.detect { |component| component.predicate == predicate }
    end

    def measure_by_predicate(predicate)
      data_structure.measures.detect { |component| component.predicate == predicate }
    end

    class << self
      def iri
        NS.cube[:DataSet]
      end

      def preview_includes
        [:observations, data_structure: %i[measures dimensions]]
      end
    end
  end
end
