# frozen_string_literal: true

class BlogPostSerializer < ContentEdgeSerializer
  include Commentable::Serializer
  include_menus
end
