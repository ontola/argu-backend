# frozen_string_literal: true

class ArgumentSerializer < ContentEdgeSerializer
  include Commentable::Serializer
  attribute :content, key: :text
  attribute :display_name, key: :name
  attributes :pro
end
