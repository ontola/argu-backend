# frozen_string_literal: true

class ArgumentActionList < EdgeActionList
  include VotesHelper

  has_action(
    :create_vote,
    result: Vote,
    type: -> { [NS::ONTOLA[:VoteAction], NS::ONTOLA[:CreateVoteAction]] },
    image: 'fa-arrow-up',
    policy: :create_child?,
    policy_resource: -> { resource.vote_collection },
    url: -> { RDF::DynamicURI(vote_iri(resource, current_vote)) },
    http_method: :post,
    favorite: true,
    condition: -> { current_vote.nil? }
  )

  has_action(
    :destroy_vote,
    result: Vote,
    type: -> { [NS::ONTOLA[:VoteAction], NS::ONTOLA[:DestroyVoteAction]] },
    image: 'fa-arrow-up',
    policy: :create_child?,
    policy_resource: -> { resource.vote_collection },
    url: -> { RDF::DynamicURI(vote_iri(resource, Vote.new)) },
    http_method: :delete,
    favorite: true,
    condition: -> { current_vote.present? }
  )

  private

  def current_vote
    @current_vote ||= upvote_for(resource, user_context.user.profile)
  end
end
