# frozen_string_literal: true

module Discussable
  extend ActiveSupport::Concern

  included do
    has_many :discussions, through: :edge

    with_collection :discussions,
                    includes: [:parent, :default_vote_event, owner: [:default_cover_photo, creator: :profileable]],
                    pagination: true
  end

  module Serializer
    extend ActiveSupport::Concern

    included do
      with_collection :discussions, predicate: NS::ARGU[:questions]
    end
  end
end
