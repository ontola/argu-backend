# frozen_string_literal: true

class ArgumentSerializer < ContentEdgeSerializer
  include Commentable::Serializer
  attribute :content, predicate: RDF::SCHEMA[:text], key: :body
  attribute :display_name, predicate: RDF::SCHEMA[:name], key: :name
  attribute :pro, predicate: RDF::SCHEMA[:option]
  include_menus
end
