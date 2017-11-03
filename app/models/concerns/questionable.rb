# frozen_string_literal: true

module Questionable
  extend ActiveSupport::Concern

  module Serializer
    extend ActiveSupport::Concern
    included do
      has_one :question_collection, predicate: NS::ARGU[:questions]

      def question_collection
        object.question_collection(user_context: scope)
      end
    end
  end
end
