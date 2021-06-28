# frozen_string_literal: true

module Motionable
  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :motions, predicate: NS.argu[:motions]
    end
  end
end
