# frozen_string_literal: true

class Vote < Edge
  include PublicActivity::Model
  include Loggable

  property :for, :integer, NS::SCHEMA[:option], default: 3, enum: {con: 0, pro: 1, neutral: 2, abstain: 3}
  property :comment_id, :linked_edge_id, NS::ARGU[:explanation]
  attribute :primary, :boolean, default: true

  has_many :activities, -> { order(:created_at) }, as: :trackable
  belongs_to :comment, foreign_key_property: :comment_id

  before_save :set_voteable_id
  before_create :trash_primary_votes
  before_create :create_confirmation_reminder_notification
  after_trash :remove_primary

  define_model_callbacks :redis_save, only: :before
  before_redis_save :trash_primary_votes
  before_redis_save :remove_other_temporary_votes

  parentable :argument, :vote_event, :linked_record

  filterable option: {
    attr: :for, key: :for, values: {yes: Vote.fors[:pro], other: Vote.fors[:neutral], no: Vote.fors[:con]}
  }
  counter_cache votes_pro: {confirmed: true, for: Vote.fors[:pro]},
                votes_con: {confirmed: true, for: Vote.fors[:con]},
                votes_neutral: {confirmed: true, for: Vote.fors[:neutral]}
  delegate :create_confirmation_reminder_notification, to: :publisher
  delegate :voteable, to: :parent_model

  validates :creator, :for, presence: true

  # #########methods###########
  def argument_ids
    @argument_ids ||= upvoted_arguments.pluck(:id)
  end

  def upvoted_arguments
    @upvoted_arguments ||=
      if !publisher.guest?
        Argument
          .untrashed
          .joins(edge: :votes)
          .joins(Edge.join_owner_query('Vote'))
          .where(votes: {creator_id: creator.id}, edges: {parent_id: parent_model&.edge&.parent_id})
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
                  parent: parent_model&.edge&.parent,
                  parent_edge: {owner_type: 'Argument'}
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

  def iri_opts
    super.merge(parent_iri: parent_iri(only_path: true))
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

  def set_voteable_id
    parent_edge.save! && parent_edge.reload if parent_edge.uuid.nil?
    self.voteable_id = parent_edge.uuid
  end

  def trash_primary_votes
    creator
      .votes
      .untrashed
      .joins(:edge)
      .where(edges: {parent_id: edge.parent_id})
      .where('? IS NULL OR votes.id != ?', id, id)
      .find_each { |primary| primary.edge.trash }
  end
end
