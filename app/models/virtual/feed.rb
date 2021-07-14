# frozen_string_literal: true

class Feed < VirtualResource
  PUBLISH_KEYS = %w[question.publish motion.publish topic.publish argument.publish pro_argument.publish
                    con_argument.publish blog_post.publish decision.approved decision.rejected comment.publish
                    intervention.publish measure.publish].freeze
  TRASH_KEYS = %w[question.trash motion.trash topic.trash argument.trash pro_argument.trash con_argument.trash
                  blog_post.trash decision.trash comment.trash intervention.trash measure.trash].freeze
  RELEVANT_KEYS = PUBLISH_KEYS + TRASH_KEYS

  attr_accessor :parent, :relevant_only

  with_collection :activities,
                  part_of: :parent,
                  default_type: :infinite,
                  parent_uri_template_opts: ->(r) { r.relevant_only ? {} : {complete: true} }

  def activities
    @activities ||=
      case parent
      when User
        user_activities
      else
        raise "#{parent.class} is not a valid parent type for generating a feed" unless parent.is_a?(Edge)

        edge_activities
      end
  end

  def root_id
    ActsAsTenant.current_tenant.uuid
  end

  delegate :root_relative_iri, to: :parent

  def root
    @root ||= Page.find_by(uuid: root_id)
  end

  private

  def activity_base
    scope = Activity
              .includes(:owner)
              .joins(:trackable, :recipient)
              .where('edges.owner_type != ?', 'Banner')
              .where('edges.owner_type != ? OR recipients_activities.owner_type != ?', 'Vote', 'Argument')
    scope = scope.where(edges: {root_id: root_id}) if root_id
    return scope unless relevant_only

    scope.where("key IN (?) AND (edges.trashed_at IS NULL OR key ~ '*.trash')", RELEVANT_KEYS)
  end

  def edge_activities
    activity_base.where(edges: {root_id: parent.root_id}).where('edges.path <@ ?', parent.path)
  end

  def user_activities
    activity_base.where(owner_id: parent.profile.id)
  end

  class << self
    def requested_index_resource(params, user_context)
      parent = LinkedRails.iri_mapper.parent_from_params(params, user_context)
      return unless parent&.enhanced_with?(Feedable)

      feed = Feed.new(
        parent: parent,
        relevant_only: true
      )

      feed.activity_collection(index_collection_params(params, user_context))
    end
  end
end
