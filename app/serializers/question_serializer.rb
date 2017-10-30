# frozen_string_literal: true

class QuestionSerializer < ContentEdgeSerializer
  include Attachable::Serializer
  include Commentable::Serializer
  include Motionable::Serializer
  attribute :display_name, predicate: RDF::SCHEMA[:display_name]
  attribute :content, predicate: RDF::SCHEMA[:text], key: :body
  include_menus
end
