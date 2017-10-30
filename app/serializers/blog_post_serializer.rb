# frozen_string_literal: true

class BlogPostSerializer < ContentEdgeSerializer
  include Commentable::Serializer
  attribute :title, predicate: RDF::SCHEMA[:name]
  attribute :content, predicate: 'http//schema.org/text', key: :body
  include_menus
end
