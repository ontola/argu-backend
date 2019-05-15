# frozen_string_literal: true

module DataCube
  class Observation < LinkedRails::Resource
    attr_accessor :data_set, :dimensions, :measures

    class << self
      def iri
        NS::CUBE[:Observation]
      end
    end
  end
end
