# frozen_string_literal: true

class Argument < Edge
  VOTE_OPTIONS = [:yes].freeze unless defined?(VOTE_OPTIONS)

  enhance ActivePublishable
  enhance Commentable
  enhance Convertible
  enhance Contactable
  enhance Feedable
  enhance Statable
  enhance Votable

  include VotesHelper

  validates :description, presence: false, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 75}
  validates :creator, presence: true

  convertible comments: %i[activities]
  counter_cache true
  paginates_per 5
  parentable :motion

  attr_reader :pro

  alias pro? pro

  def default_vote_event
    self
  end

  def pro=(value)
    value = false if %w[con false].include?(value)
    @pro = value.to_s == 'pro' || value
  end

  def upvote_only?
    true
  end

  def upvote(user, profile) # rubocop:disable Metrics/MethodLength
    service = CreateVote.new(
      self,
      attributes: {
        option: :yes,
        creator: profile
      },
      options: {
        user_context: UserContext.new(profile: profile, user: user)
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
    def inherited(klass)
      klass.include Edgeable::Content

      super
    end

    def route_key
      :a
    end
  end
end
