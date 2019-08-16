# frozen_string_literal: true

module InterventionTypeable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :intervention_types, predicate: NS::RIVM[:interventionTypes]
    end
  end
end
