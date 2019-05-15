# frozen_string_literal: true

module DataCube
  class Set < LinkedRails::Resource
    attr_accessor :description, :dimensions, :label, :measures, :observations

    def initialize(opts = {})
      super
      observations.map! do |observation|
        Observation.new(
          data_set: self,
          dimensions: Hash[observation[:dimensions].map { |key, value| [dimension_by_predicate(key), value] }],
          measures: Hash[observation[:measures].map { |key, value| [measure_by_predicate(key), value] }]
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
        NS::CUBE[:DataSet]
      end
    end
  end
end
