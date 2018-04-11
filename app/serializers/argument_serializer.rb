# frozen_string_literal: true

class ArgumentSerializer < ContentEdgeSerializer
  include Commentable::Serializer
  include VotesHelper

  with_collection :votes, predicate: NS::ARGU[:votes]
  has_one :current_vote,
          predicate: NS::ARGU[:currentVote],
          unless: :service_scope?

  attribute :pro, predicate: NS::SCHEMA[:option]

  include_menus
  include_actions

  def current_vote
    @current_vote ||= upvote_for(object, scope.user.profile)
  end
end
