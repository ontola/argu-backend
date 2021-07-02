# frozen_string_literal: true

class Vote < Edge
  extend UriTemplateHelper

  enhance LinkedRails::Enhancements::Creatable
  enhance Trashable
  enhance Loggable
  enhance LinkedRails::Enhancements::Updatable
  enhance Singularable
  include RedisResource::Concern

  property :option, :integer, NS.schema.option, default: 3, enum: {no: 0, yes: 1, other: 2, abstain: 3}
  property :comment_id, :linked_edge_id, NS.argu[:explanation]
  attribute :primary, :boolean, default: true

  belongs_to :comment, foreign_key_property: :comment_id

  before_create :trash_primary_votes
  before_create :create_confirmation_reminder_notification
  after_trash :remove_primary

  before_redis_save :trash_primary_votes
  before_redis_save :remove_other_temporary_votes

  parentable :pro_argument, :con_argument, :vote_event

  filterable NS.schema.option => {
    values: Vote.options,
    counter_cache: {yes: :votes_pro, other: :votes_neutral, no: :votes_con}
  }
  counter_cache votes_pro: {confirmed: true, option: Vote.options[:yes]},
                votes_con: {confirmed: true, option: Vote.options[:no]},
                votes_neutral: {confirmed: true, option: Vote.options[:other]},
                votes: {confirmed: true}
  delegate :voteable, to: :parent

  validates :creator, :option, presence: true

  def cacheable?
    false
  end

  # Needed for ActivityListener#audit_data
  def display_name
    "#{option} vote for #{parent.display_name}"
  end

  def pinned_at
    nil
  end

  def searchable_should_index?
    false
  end

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
    def abstain_vote(parent, user_context)
      new(
        is_published: true,
        parent: parent,
        publisher: user_context&.user,
        creator: user_context&.profile
      )
    end

    def anonymize(collection)
      collection.destroy_all
    end

    def attributes_for_new(opts)
      attrs = super
      attrs[:primary] = true
      attrs
    end

    def current_vote(parent, user_context)
      return nil if user_context.nil?

      Vote
        .where_with_redis(creator: user_context.profile, root_id: ActsAsTenant.current_tenant.uuid)
        .find_by(parent: parent, primary: true)
    end

    def requested_singular_resource(params, user_context)
      parent = LinkedRails.iri_mapper.parent_from_params(params, user_context)
      return unless parent.enhanced_with?(Votable)

      current_vote(parent, user_context) || abstain_vote(parent, user_context)
    end

    def singular_route_key
      :vote
    end
  end
end
