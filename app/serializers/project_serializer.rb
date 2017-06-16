# frozen_string_literal: true

class ProjectSerializer < ContentEdgeSerializer
  attributes :display_name, :content
  include_menus

  has_many :phases
  has_many :blog_posts
end
