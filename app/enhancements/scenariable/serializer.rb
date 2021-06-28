# frozen_string_literal: true

module Scenariable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :scenarios, predicate: NS.rivm[:scenarios]
    end
  end
end
