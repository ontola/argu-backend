# frozen_string_literal: true
class QuestionSerializer < BaseEdgeSerializer
  attributes :display_name, :content, :potential_action
  has_many :motions do
    link(:self) do
      {
        href: "#{object.class.try(:context_id_factory)&.call(object)}/m",
        meta: {
          '@type': 'argu:collectionAssociation'
        }
      }
    end
  end
end
