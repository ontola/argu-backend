# frozen_string_literal: true

class ArgumentSerializer < ContentEdgeSerializer
  include Commentable::Serializer
  attribute :pro, predicate: RDF::SCHEMA[:option]
  include_menus
end
