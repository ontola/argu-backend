# frozen_string_literal: true

class BlogPostSerializer < ContentEdgeSerializer
  include Commentable::Serializer
  attributes :title, :content
  include_menus

  belongs_to :creator
end
