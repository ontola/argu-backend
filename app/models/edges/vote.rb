# frozen_string_literal: true

class Vote < Edge # rubocop:disable Metrics/ClassLength
  extend URITemplateHelper

  enhance LinkedRails::Enhancements::Creatable
  enhance Trashable
  enhance Loggable
  enhance LinkedRails::Enhancements::Updatable
  enhance Singularable
  include RedisResource::Concern

  property :option_id, :linked_edge_id, NS.schema.option, association_class: 'Term'
  property :comment_id, :linked_edge_id, NS.argu[:explanation]
  attribute :primary, :boolean, default: true

  before_create :trash_primary_votes
  before_create :create_confirmation_reminder_notification
  after_trash :remove_primary

  before_redis_save :trash_primary_votes
  before_redis_save :remove_other_temporary_votes

  parentable :pro_argument, :con_argument, :vote_event

  filterable NS.schema.option => {
    filter: lambda do |scope, values|
      scope.where(option_id: option_ids_from_values(values))
    end,
    values_in: -> { collection.parent.options_vocab&.term_collection&.iri }
  }
  counter_cache(
    lambda do
      option_ids = Property.where(predicate: NS.schema.option).distinct.pluck(:linked_edge_id)
      option_ids.reduce(default_cache_opts) do |opts, option_id|
        opts.merge(
          option_id => {confirmed: true, option_id: option_id}
        )
      end
    end
  )
  delegate :voteable, to: :parent

  validates :option, presence: true

  def cacheable?
    false
  end

  # Needed for ActivityListener#audit_data
  def display_name
    "#{option&.display_name} vote for #{parent.display_name}"
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
        active_branch: parent.active_branch,
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
        .where_with_redis(publisher: user_context.user, root_id: ActsAsTenant.current_tenant.uuid)
        .find_by(parent: parent, primary: true)
    end

    def default_cache_opts
      {votes: {confirmed: true}}
    end

    def option_ids_from_values(values)
      Edge.where(fragment: values.map { |value| Term.fragment_from_iri(value) }).distinct.pluck(:uuid)
    end

    def requested_singular_resource(params, user_context)
      parent = LinkedRails.iri_mapper.parent_from_params(params, user_context)
      return unless parent&.enhanced_with?(Votable)

      current_vote(parent, user_context) || abstain_vote(parent, user_context)
    end

    def singular_route_key
      :vote
    end
  end
end
