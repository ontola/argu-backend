# frozen_string_literal: true
class QuestionSerializer < BaseEdgeSerializer
  attributes :display_name, :content, :potential_action
  has_many :motions do
    meta do
      href = object.class.try(:context_id_factory)&.call(object)
      {
        '@type': 'http://schema.org/relation',
        '@id': "#{href}/m"
      }
    end
  end
end
