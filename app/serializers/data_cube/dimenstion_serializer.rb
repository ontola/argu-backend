# frozen_string_literal: true

module DataCube
  class DimensionSerializer < ComponentSerializer
    attribute :predicate, predicate: NS::CUBE[:dimension]
  end
end
