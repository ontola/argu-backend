# frozen_string_literal: true

class PollSerializer < EdgeSerializer
  has_one :vote_options, predicate: NS.argu[:voteOptionsCollection] do |object, params|
    object.options_vocab.term_collection(user_context: params[:scope])
  end
end
