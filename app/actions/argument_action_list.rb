# frozen_string_literal: true

class ArgumentActionList < EdgeActionList
  include VotesHelper

  has_action(
    :vote,
    result: Vote,
    type: -> { [NS::ONTOLA[:VoteAction], NS::ONTOLA[:"#{vote_action.to_s.camelize}VoteAction"]] },
    image: 'fa-arrow-up',
    policy: :create_child?,
    policy_resource: -> { resource.vote_collection },
    url: -> { RDF::DynamicURI(vote_iri(resource, vote_action == :create ? current_vote : Vote.new)) },
    action_tag: -> { :"#{vote_action}_vote" },
    http_method: -> { vote_action == :create ? :post : :delete },
    favorite: true
  )

  private

  def vote_action
    @vote_action ||= vote_method(current_vote) == :post ? :create : :destroy
  end

  def current_vote
    @current_vote ||= upvote_for(resource, user_context.user.profile)
  end
end
