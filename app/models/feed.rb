# frozen_string_literal: true

class Feed
  RELEVANT_KEYS = %w[question.publish motion.publish argument.create pro_argument.create con_argument.create
                     blog_post.publish decision.approved decision.rejected comment.create].freeze

  include ActiveModel::Model
  include Ldable
  include Iriable
  attr_accessor :parent, :relevant_only, :root_id

  with_collection :activities, part_of: :parent

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

  def canonical_iri(opts)
    parent&.canonical_iri(opts)
  end

  def iri(opts = {})
    parent&.iri(opts)
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
    scope.where('key IN (?)', RELEVANT_KEYS)
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
end
