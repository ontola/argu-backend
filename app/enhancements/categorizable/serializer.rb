# frozen_string_literal: true

module Categorizable
  module Serializer
    extend ActiveSupport::Concern

    included do
      attribute :category_id, predicate: NS::RIVM[:category], if: method(:never)

      has_one :category, predicate: NS::RIVM[:category]
    end
  end
end
