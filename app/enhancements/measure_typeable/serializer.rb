# frozen_string_literal: true

module MeasureTypeable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :measure_types, predicate: NS::RIVM[:measureTypes]
    end
  end
end
