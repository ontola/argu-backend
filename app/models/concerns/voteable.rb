# frozen_string_literal: true
module Voteable
  extend ActiveSupport::Concern
  include PragmaticContext::Contextualizable

  included do
    contextualize :votes_pro_count, as: 'http://schema.org/upvoteCount'
    contextualize :votes_neutral_count, as: 'http://schema.org/abstainvoteCount'
    contextualize :votes_con_count, as: 'http://schema.org/downvoteCount'
  end
end
