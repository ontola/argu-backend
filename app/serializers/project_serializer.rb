# frozen_string_literal: true

class ProjectSerializer < ContentEdgeSerializer
  attribute :display_name, predicate: RDF::SCHEMA[:name]
  attribute :content, predicate: RDF::SCHEMA[:text], key: :body
  include_menus

  has_many :phases
  has_many :blog_posts
end
