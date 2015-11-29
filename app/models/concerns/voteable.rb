# Small Interface module for supporting the not-so-very-well implemented active counter cache updating
# Especially for interactions count, since it spreads like a cancer up the lineage
module Voteable
  extend ActiveSupport::Concern

  # The possible options for `for`, the options must be within the domain `Vote.fors`'s keys
  VOTE_OPTIONS = []

  module InstanceMethods
    has_many :votes,
             as: :voteable,
             dependent: :destroy,
             inverse_of: :voteable
  end

end
