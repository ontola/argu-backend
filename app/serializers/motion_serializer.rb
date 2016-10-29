# frozen_string_literal: true

class MotionSerializer < BaseCommentSerializer
  include Loggable::Serlializer

  attributes :content
  has_many :arguments do
    link(:related) do
      {
        href: "#{url_for(object)}/arguments",
        meta: {
          '@type': 'http://schema.org/arguments'
        }
      }
    end
  end
end
