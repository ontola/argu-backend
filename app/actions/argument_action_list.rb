# frozen_string_literal: true

class ArgumentActionList < EdgeActionList
  include VotesHelper

  has_action(
    :create_vote,
    completed: -> { current_vote.present? },
    result: Vote,
    type: -> { [NS::ONTOLA[:VoteAction], NS::ONTOLA[:CreateVoteAction]] },
    image: 'fa-arrow-up',
    policy: :up_vote?,
    url: -> { collection_iri(resource, :votes, CGI.escape(NS::SCHEMA[:option]) => :yes) },
    http_method: :post,
    favorite: true,
    condition: -> { current_vote.nil? }
  )

  has_action(
    :destroy_vote,
    completed: -> { current_vote.nil? },
    result: Vote,
    type: -> { [NS::ONTOLA[:VoteAction], NS::ONTOLA[:DestroyVoteAction]] },
    image: 'fa-arrow-up',
    policy: :down_vote?,
    url: -> { vote_iri(resource, Vote.new) },
    http_method: :delete,
    favorite: true,
    condition: -> { current_vote.present? }
  )

  private

  def current_vote
    @current_vote ||= upvote_for(resource, user_context.user.profile)
  end
end
