# frozen_string_literal: true

class Argument < Edge
  enhance ActivePublishable
  enhance Commentable
  enhance Convertible
  enhance Contactable
  enhance Feedable
  enhance Statable
  enhance Votable

  validates :description, presence: false, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 75}

  convertible comments: %i[activities]
  counter_cache true
  paginates_per 5
  parentable :motion

  after_create :auto_upvote

  attr_reader :pro

  alias pro? pro

  def default_vote_event
    self
  end

  def options_vocab
    Vocabulary.upvote_options
  end

  def pro=(value)
    value = false if %w[con false].include?(value)
    @pro = value.to_s == 'pro' || value
  end

  def upvote(user, profile) # rubocop:disable Metrics/MethodLength
    service = CreateVote.new(
      self,
      attributes: {
        option: NS.argu[:yes],
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

  private

  def auto_upvote
    upvote(publisher, creator)
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
