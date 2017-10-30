# frozen_string_literal: true

class MotionSerializer < ContentEdgeSerializer
  include Argumentable::Serializer
  include Attachable::Serializer
  include Commentable::Serializer
  include Voteable::Serializer
  attribute :content, predicate: RDF::SCHEMA[:text], key: :body
  attribute :current_vote, predicate: RDF::ARGU[:currentVote]
  include_menus

  def current_vote
    object.current_vote&.for
  end
end
