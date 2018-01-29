# frozen_string_literal: true

module Motionable
  extend ActiveSupport::Concern

  included do
    with_collection :motions, pagination: true
  end

  module Serializer
    extend ActiveSupport::Concern
    included do
      # rubocop:disable Rails/HasManyOrHasOneDependent
      has_one :motion_collection, predicate: NS::ARGU[:motions]
      # rubocop:enable Rails/HasManyOrHasOneDependent

      def motion_collection
        object.motion_collection(user_context: scope)
      end
    end
  end
end
