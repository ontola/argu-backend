# frozen_string_literal: true

class Argument < Edge
  VOTE_OPTIONS = [:pro].freeze unless defined?(VOTE_OPTIONS)

  enhance LinkedRails::Enhancements::Creatable
  enhance ActivePublishable
  enhance Commentable
  enhance Convertible
  enhance Contactable
  enhance Feedable
  enhance Statable

  include Edgeable::Content
  include VotesHelper

  validates :description, presence: false, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 75}
  validates :creator, presence: true

  convertible comments: %i[activities]
  counter_cache true
  paginates_per 5
  parentable :motion
  with_collection :votes

  attr_reader :pro

  alias pro? pro

  def default_vote_event
    self
  end

  def pro=(value)
    value = false if %w[con false].include?(value)
    @pro = value.to_s == 'pro' || value
  end

  def upvote(user, profile) # rubocop:disable Metrics/MethodLength
    service = CreateVote.new(
      self,
      attributes: {
        for: :pro,
        creator: profile
      },
      options: {
        creator: profile,
        publisher: user
      }
    )
    service.on(:create_vote_failed) do
      raise 'Failed to upvote'
    end
    service.commit
  end

  def voteable
    self
  end

  class << self
    def includes_for_serializer
      super.merge(votes: {})
    end
  end
end
