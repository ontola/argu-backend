# frozen_string_literal: true
class ArgumentSerializer < BaseEdgeSerializer
  include Commentable::Serlializer
  attribute :content, key: :text
  attribute :display_name, key: :name
  attributes :pro
end
