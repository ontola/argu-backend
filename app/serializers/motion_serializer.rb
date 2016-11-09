# frozen_string_literal: true
class MotionSerializer < BaseCommentSerializer
  include Loggable::Serlializer

  attributes :content
  has_many :arguments do
    link(:related) do
      {
        '@type': 'http://schema.org/relation',
        href: "#{url_for(object)}/arguments",
        meta: {
          '@type': 'http://schema.org/arguments'
        }
      }
    end
    meta do
      href = object.class.try(:context_id_factory)&.call(object)
      {
        '@type': 'http://schema.org/relation',
        '@id': "#{href}/arguments"
      }
    end
  end
end
