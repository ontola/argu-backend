# frozen_string_literal: true

module Riskable
  module Serializer
    extend ActiveSupport::Concern

    included do
      attribute :example_of_id, predicate: NS::RIVM[:exampleOf], if: :never

      with_collection :risks, predicate: NS::RIVM[:exampleOf]
    end
  end
end
