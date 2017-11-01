# frozen_string_literal: true

class ContentEdgeSerializer < BaseEdgeSerializer
  include Loggable::Serializer
  include Menuable::Serializer

  attribute :content, predicate: RDF::SCHEMA[:text]
end
