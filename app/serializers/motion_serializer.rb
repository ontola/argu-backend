# frozen_string_literal: true
class MotionSerializer < BaseCommentSerializer
  include Loggable::Serlializer
  attributes :content

  has_many :arguments do
    link(:self) do
      {
        href: "#{object.class.try(:context_id_factory)&.call(object)}/arguments",
        meta: {
          '@type': 'schema:arguments'
        }
      }
    end
    meta do
      href = object.class.try(:context_id_factory)&.call(object)
      {
        '@type': 'argu:collectionAssociation',
        '@id': "#{href}/c"
      }
    end
  end
end
