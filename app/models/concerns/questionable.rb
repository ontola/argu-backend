# frozen_string_literal: true

module Questionable
  extend ActiveSupport::Concern

  included do
    with_collection :questions, pagination: true
  end

  module Serializer
    extend ActiveSupport::Concern
    included do
      # rubocop:disable Rails/HasManyOrHasOneDependent
      has_one :question_collection, predicate: NS::ARGU[:questions]
      # rubocop:enable Rails/HasManyOrHasOneDependent

      def question_collection
        object.question_collection(user_context: scope)
      end
    end
  end
end
