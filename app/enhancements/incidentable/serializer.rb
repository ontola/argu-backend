# frozen_string_literal: true

module Incidentable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :incidents, predicate: NS::RIVM[:incidents]
    end
  end
end
