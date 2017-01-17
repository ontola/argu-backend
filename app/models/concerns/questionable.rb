# frozen_string_literal: true
module Questionable
  extend ActiveSupport::Concern

  module Serlializer
    extend ActiveSupport::Concern
    included do
      has_one :question_collection do
        link(:self) do
          {
            href: "#{object.context_id}/questions",
            meta: {
              '@type': 'argu:questions'
            }
          }
        end
        meta do
          href = object.context_id
          {
            '@type': 'argu:collectionAssociation',
            '@id': "#{href}/questions"
          }
        end
      end

      def question_collection
        object.question_collection(user_context: scope)
      end
    end
  end
end
