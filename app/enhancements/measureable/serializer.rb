# frozen_string_literal: true

module Measureable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :measures, predicate: NS.rivm[:measures]
    end
  end
end
