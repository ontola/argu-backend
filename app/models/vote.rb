# frozen_string_literal: true

class Vote < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance Loggable
  enhance LinkedRails::Enhancements::Updatable

  include RedisResource::Concern
  include Trashable::Model

  property :option, :integer, NS::SCHEMA[:option], default: 3, enum: {no: 0, yes: 1, other: 2, abstain: 3}
  property :comment_id, :linked_edge_id, NS::ARGU[:explanation]
  OPINION_CLASSES = {
    yes: 'ProOpinion',
    other: 'NeutralOpinion',
    no: 'ConOpinion'
  }.with_indifferent_access
  attribute :primary, :boolean, default: true

  belongs_to :comment, foreign_key_property: :comment_id

  before_create :trash_primary_votes
  before_create :create_confirmation_reminder_notification
  after_trash :remove_primary

  before_redis_save :trash_primary_votes
  before_redis_save :remove_other_temporary_votes

  parentable :pro_argument, :con_argument, :vote_event

  filterable NS::SCHEMA[:option] => {
    values: Vote.options,
    counter_cache: {yes: :votes_pro, other: :votes_neutral, no: :votes_con}
  }
  counter_cache votes_pro: {confirmed: true, option: Vote.options[:yes]},
                votes_con: {confirmed: true, option: Vote.options[:no]},
                votes_neutral: {confirmed: true, option: Vote.options[:other]},
                votes: {confirmed: true}
  delegate :voteable, to: :parent

  validates :creator, :option, presence: true

  # Needed for ActivityListener#audit_data
  def display_name
    "#{option} vote for #{parent.display_name}"
  end

  def iri_opts
    super.merge(parent_iri: parent_iri_path)
  end

  def iri_template_name
    return super unless store_in_redis?

    :vote_iri
  end

  def is_pro_con?
    true
  end

  def opinion_class
    OPINION_CLASSES[option] || raise("Could not find an OpinionClass for #{option}")
  end

  def pinned_at
    nil
  end

  def searchable_should_index?
    false
  end

  delegate :is_trashed?, :trashed_at, to: :parent, allow_nil: true

  private

  def create_confirmation_reminder_notification
    publisher.create_confirmation_reminder_notification(root_id)
  end

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

  class << self
    def anonymize(collection)
      collection.destroy_all
    end

    def includes_for_serializer
      super.merge(publisher: {}, comment: :properties)
    end
  end
end
