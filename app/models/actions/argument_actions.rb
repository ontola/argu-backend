# frozen_string_literal: true

class ArgumentActions < ActionList
  include VotesHelper

  cattr_accessor :defined_actions
  define_actions %i[vote]

  private

  def vote_action
    vote = upvote_for(resource, current_user.actor)

    if vote_method(vote) == :post
      action_item(
        :create_vote,
        target: create_vote_entrypoint(vote),
        result: Vote,
        type: [NS::ARGU[:VoteAction], NS::ARGU[:CreateVoteAction]],
        policy: :vote?
      )
    else
      action_item(
        :destroy_vote,
        target: destroy_vote_entrypoint,
        result: Vote,
        type: [NS::ARGU[:VoteAction], NS::ARGU[:DestroyVoteAction]],
        policy: :vote?
      )
    end
  end

  def create_vote_entrypoint(vote)
    entry_point_item(
      :upvote,
      image: 'fa-arrow-up',
      url: RDF::URI(vote_iri(resource, vote)),
      http_method: vote_method(vote)
    )
  end

  def destroy_vote_entrypoint
    entry_point_item(
      :upvote,
      image: 'fa-arrow-up',
      url: RDF::URI(resource.pro ? pro_argument_vote_url(resource) : con_argument_vote_url(resource)),
      http_method: :delete
    )
  end
end
