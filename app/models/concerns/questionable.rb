# frozen_string_literal: true
module Questionable
  extend ActiveSupport::Concern

  included do
    def question_collection(opts = {})
      Collection.new(
        {
          parent: self,
          association: :questions,
          pagination: true,
          uri: "#{context_id}/questions"
        }.merge(opts)
      )
    end
  end

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
    end
  end
end
