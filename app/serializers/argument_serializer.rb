# frozen_string_literal: true

class ArgumentSerializer < ContentEdgeSerializer
  include Commentable::Serializer
  attribute :content, key: :text
  attribute :display_name, key: :name
  attributes :pro
  include_menus

  has_one :argument_collection do
    link(:self) do
      {
        href: "#{object.parent_model.context_id}/arguments",
        meta: {
          '@type': 'schema:arguments'
        }
      }
    end
    meta do
      href = object.context_id
      {
        '@type': 'argu:member',
        '@id': "#{href}/arguments"
      }
    end
  end

  def argument_collection
    object.comment_collection(user_context: scope)
  end
end
