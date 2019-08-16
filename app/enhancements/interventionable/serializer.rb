# frozen_string_literal: true

module Interventionable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :interventions, predicate: NS::RIVM[:interventions]
    end
  end
end
