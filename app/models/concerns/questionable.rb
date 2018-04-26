# frozen_string_literal: true

module Questionable
  extend ActiveSupport::Concern

  included do
    with_collection :questions, pagination: true
  end

  module Actions
    extend ActiveSupport::Concern

    included do
      include ActionableHelper

      define_action :question

      def question_action
        action_item(
          :create_question,
          target: question_entrypoint,
          resource: resource.question_collection,
          result: Question,
          type: [
            NS::ARGU[:CreateAction],
            NS::SCHEMA[:QuestionAction],
            NS::ARGU[:CreateQuestion]
          ],
          policy: :question?
        )
      end

      def question_entrypoint
        entry_point_item(
          :create_question,
          image: 'fa-question',
          url: collection_create_url(:question),
          http_method: 'POST'
        )
      end
    end
  end

  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :questions, predicate: NS::ARGU[:questions]

      def question_collection
        object.question_collection(user_context: scope)
      end
    end
  end
end
