# frozen_string_literal: true

class Blog < ContainerNode
  enhance BlogPostable

  self.default_widgets = %i[blog_posts]
end
