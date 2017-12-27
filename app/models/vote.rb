# frozen_string_literal: true

class Vote < Edgeable::Base
  include PublicActivity::Model
  include Loggable

  belongs_to :creator, class_name: 'Profile', inverse_of: :votes
  belongs_to :publisher, class_name: 'User', foreign_key: 'publisher_id', inverse_of: :votes
  has_many :activities, -> { order(:created_at) }, as: :trackable
  belongs_to :forum
  belongs_to :comment
  before_create :trash_primary_votes
  after_trash :remove_primary

  define_model_callbacks :redis_save, only: :before
  before_redis_save :trash_primary_votes
  before_redis_save :remove_other_temporary_votes
  before_redis_save :create_confirmation_reminder_notification

  parentable :argument, :vote_event, :linked_record

  enum for: {con: 0, pro: 1, neutral: 2, abstain: 3}
  filterable option: {key: 'votes.for', values: {yes: Vote.fors[:pro], other: Vote.fors[:neutral], no: Vote.fors[:con]}}
  counter_cache votes_pro: {for: Vote.fors[:pro]},
                votes_con: {for: Vote.fors[:con]},
                votes_neutral: {for: Vote.fors[:neutral]}
  delegate :create_confirmation_reminder_notification, to: :publisher
  delegate :voteable, to: :parent_model

  validates :creator, :for, presence: true

  # #########methods###########
  def argument_ids
    @argument_ids ||= upvoted_arguments.pluck(:id)
  end

  def upvoted_arguments
    @upvoted_arguments ||=
      if creator.confirmed?
        Argument
          .untrashed
          .joins(:votes, :edge)
          .where(votes: {creator: creator}, edges: {parent_id: parent_model&.edge&.parent_id})
      else
        Argument
          .untrashed
          .joins(:edge)
          .where(
            edges: {
              id:
                Edge.where_owner(
                  'Vote',
                  creator: creator,
                  path: "#{parent_model&.edge&.parent&.path}.*",
                  voteable_type: 'Argument'
                ).pluck(:parent_id)
            }
          )
      end
  end

  # Needed for ActivityListener#audit_data
  def display_name
    "#{self.for} vote for #{parent_model.display_name}"
  end

  def for?(item)
    self.for.to_s == item.to_s
  end

  def is_pro_con?
    true
  end

  def key
    self.for.to_sym
  end

  def pinned_at
    nil
  end

  def store_in_redis?(opts = {})
    !opts[:skip_redis] && !publisher.confirmed? && !creator.confirmed?
  end

  delegate :is_trashed?, :trashed_at, to: :parent_model

  # #########Class methods###########
  def self.ordered(votes)
    grouped = votes.to_a.group_by(&:for)
    HashWithIndifferentAccess.new(
      pro: {collection: grouped['pro'] || []},
      neutral: {collection: grouped['neutral'] || []},
      con: {collection: grouped['con'] || []}
    )
  end

  private

  def remove_other_temporary_votes
    key = RedisResource::Resource.new(resource: self).send(:key).key
    Argu::Redis.delete_all(Argu::Redis.keys(key.gsub(".#{edge.id}.", '.*.')) - [key])
  end

  def remove_primary
    update!(primary: false)
  end

  def trash_primary_votes
    creator
      .votes
      .untrashed
      .where(voteable_id: voteable_id, voteable_type: voteable_type)
      .where('? IS NULL OR votes.id != ?', id, id)
      .find_each { |primary| primary.edge.trash }
  end
end
