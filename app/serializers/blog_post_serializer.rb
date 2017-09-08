# frozen_string_literal: true

class BlogPostSerializer < ContentEdgeSerializer
  include Commentable::Serializer
  attributes :title, :content

  belongs_to :creator
end
