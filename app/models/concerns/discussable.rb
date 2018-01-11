# frozen_string_literal: true

module Discussable
  extend ActiveSupport::Concern

  included do
    has_many :discussions,
             -> { where(owner_type: %w[Motion Question]) },
             through: :edge,
             source: :children,
             class_name: 'Edge'
  end

  module Serializer
    extend ActiveSupport::Concern
    included do
      # rubocop:disable Rails/HasManyOrHasOneDependent
      has_one :discussion_collection, predicate: NS::ARGU[:questions]
      # rubocop:enable Rails/HasManyOrHasOneDependent

      def discussion_collection
        object.discussion_collection(user_context: scope)
      end
    end
  end
end
