# frozen_string_literal: true

module DataCube
  class MeasureSerializer < ComponentSerializer
    attribute :predicate, predicate: NS::CUBE[:measure]
  end
end
