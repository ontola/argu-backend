# frozen_string_literal: true

module Motionable
  extend ActiveSupport::Concern

  included do
    with_collection :motions, pagination: true
  end

  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :motions, predicate: NS::ARGU[:motions]
    end
  end
end
