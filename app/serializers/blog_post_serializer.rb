# frozen_string_literal: true

class BlogPostSerializer < ContentEdgeSerializer
  include_menus

  has_one :happening, predicate: NS::ARGU[:happening]
end
