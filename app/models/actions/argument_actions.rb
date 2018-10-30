# frozen_string_literal: true

module Actions
  class ArgumentActions < EdgeActions
    include VotesHelper

    define_action(
      :vote,
      result: Vote,
      type: -> { [NS::ARGU[:VoteAction], NS::ARGU[:"#{vote_action.to_s.camelize}VoteAction"]] },
      image: 'fa-arrow-up',
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
      @current_vote ||= upvote_for(resource, current_user.actor)
    end
  end
end
