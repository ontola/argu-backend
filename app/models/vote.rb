# frozen_string_literal: true

class Vote < Edge
  enhance Createable
  enhance Destroyable
  enhance Loggable
  enhance Updateable
  enhance Actionable

  include RedisResource::Concern

  property :for, :integer, NS::SCHEMA[:option], default: 3, enum: {con: 0, pro: 1, neutral: 2, abstain: 3}
  property :comment_id, :linked_edge_id, NS::ARGU[:explanation]
  attribute :primary, :boolean, default: true

  belongs_to :comment, foreign_key_property: :comment_id

  before_create :trash_primary_votes
  before_create :create_confirmation_reminder_notification
  after_trash :remove_primary

  define_model_callbacks :redis_save, only: :before
  before_redis_save :trash_primary_votes
  before_redis_save :remove_other_temporary_votes

  parentable :pro_argument, :con_argument, :vote_event, :linked_record

  filterable option: {
    attr: :for, key: :for, values: {yes: Vote.fors[:pro], other: Vote.fors[:neutral], no: Vote.fors[:con]}
  }
  counter_cache votes_pro: {confirmed: true, for: Vote.fors[:pro]},
                votes_con: {confirmed: true, for: Vote.fors[:con]},
                votes_neutral: {confirmed: true, for: Vote.fors[:neutral]}
  delegate :create_confirmation_reminder_notification, to: :publisher
  delegate :voteable, to: :parent

  validates :creator, :for, presence: true

  # #########methods###########
  def argument_ids
    @argument_ids ||= upvoted_arguments.pluck(:id).uniq
  end

  def upvoted_arguments
    return [] if publisher.guest?
    @upvoted_arguments ||=
      Argument
        .untrashed
        .joins(:votes)
        .where(votes_edges: {creator_id: creator_id}, parent_id: parent&.parent_id)
  end

  # Needed for ActivityListener#audit_data
  def display_name
    "#{self.for} vote for #{parent.display_name}"
  end

  def for?(item)
    self.for.to_s == item.to_s
  end

  def self.includes_for_serializer
    super.merge(publisher: {}, comment: {})
  end

  def iri_opts
    super.merge(parent_iri: parent_iri(only_path: true))
  end

  def iri_template_name
    return super unless store_in_redis?
    :vote_iri
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
    !opts[:skip_redis] && publisher.guest?
  end

  delegate :is_trashed?, :trashed_at, to: :parent

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
    Argu::Redis.delete_all(Argu::Redis.keys(key.gsub(".#{id}.", '.*.')) - [key])
  end

  def remove_primary
    update!(primary: false)
  end

  def trash_primary_votes
    creator
      .votes
      .untrashed
      .where(parent_id: parent_id)
      .where('? IS NULL OR uuid != ?', uuid, uuid)
      .find_each(&:trash)
  end
end
