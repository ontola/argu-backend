# frozen_string_literal: true

class Feed
  PUBLISH_KEYS = %w[question.publish motion.publish topic.publish argument.publish pro_argument.publish
                    con_argument.publish blog_post.publish decision.approved decision.rejected comment.publish].freeze
  TRASH_KEYS = %w[question.trash motion.trash topic.trash argument.trash pro_argument.trash
                  con_argument.trash blog_post.trash decision.trash comment.trash].freeze
  RELEVANT_KEYS = PUBLISH_KEYS + TRASH_KEYS

  include ActiveModel::Model
  include LinkedRails::Model
  attr_accessor :parent, :relevant_only, :root_id

  with_collection :activities,
                  part_of: :parent,
                  default_type: :infinite,
                  parent_uri_template_opts: ->(r) { r.relevant_only ? {} : {complete: true} }

  def activities
    @activities ||=
      case parent
      when Profile
        profile_activities
      when User
        favorite_activities
      else
        raise "#{parent.class} is not a valid parent type for generating a feed" unless parent.is_a?(Edge)
        edge_activities
      end
  end

  def root_relative_canonical_iri(opts = {})
    case parent
    when User
      RDF::URI('')
    when Profile
      parent&.profileable&.root_relative_canonical_iri(opts.merge(root: root.url))
    else
      parent&.root_relative_canonical_iri(opts)
    end
  end

  def root_relative_iri(opts = {})
    case parent
    when User
      RDF::URI('/argu/staff')
    when Profile
      parent&.profileable&.root_relative_iri(opts.merge(root: root.url))
    else
      parent&.root_relative_iri(opts)
    end
  end

  def root
    @root ||= Page.find_by(uuid: root_id)
  end

  private

  def activity_base
    scope = Activity
              .includes(:owner)
              .joins(:trackable, :recipient)
              .where('edges.owner_type != ? OR recipients_activities.owner_type != ?', 'Vote', 'Argument')
    scope = scope.where(edges: {root_id: root_id}) if root_id
    return scope unless relevant_only
    scope.where("key IN (?) AND (edges.trashed_at IS NULL OR key ~ '*.trash')", RELEVANT_KEYS)
  end

  def edge_activities
    activity_base.where(edges: {root_id: parent.root_id}).where('edges.path <@ ?', parent.path)
  end

  def favorite_activities
    raise 'Staff only' unless parent.is_staff?
    return Activity.none if parent.favorites.empty?
    activity_base.where(edges: {root_id: parent.favorites.joins(:edge).pluck('edges.root_id')})
  end

  def profile_activities
    activity_base.where(owner_id: parent.id)
  end

  class << self
    def preview_includes
      [
        :trackable,
        :recipient,
        owner: [:default_profile_photo]
      ]
    end
  end
end
