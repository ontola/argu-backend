# frozen_string_literal: true
class ArgumentSerializer < BaseEdgeSerializer
  attributes :display_name, :content, :pro

  has_many :comment_threads do
    link(:self) do
      {
        href: "#{object.context_id}/c",
        meta: {
          '@type': 'schema:comments'
        }
      }
    end
    meta do
      href = object.context_id
      {
        '@type': 'http://schema.org/relation',
        '@id': "#{href}/c"
      }
    end
  end
end
