# frozen_string_literal: true

module DataCube
  class Structure < LinkedRails::Resource
    attr_accessor :data_set

    def dimensions
      @dimensions ||=
        data_set.dimensions.each_with_index.map { |predicate, i| Dimension.new(order: i, predicate: predicate) }
    end

    def measures
      @measures ||=
        data_set.measures.each_with_index.map { |predicate, i| Measure.new(order: i, predicate: predicate) }
    end

    class << self
      def iri
        NS::CUBE[:DataStructureDefinition]
      end
    end
  end
end
