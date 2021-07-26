# frozen_string_literal: true

class Feed < VirtualResource
  attr_accessor :parent

  with_collection :activities,
                  part_of: :parent,
                  default_type: :infinite

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
              .where("key ~ '#{self.class.class_key}.update|publish'")
              .where(edges: {is_published: true, trashed_at: nil})
    scope = scope.where(edges: {root_id: root_id}) if root_id
    scope
  end

  def edge_activities
    activity_base.where(edges: {root_id: parent.root_id}).where('edges.path <@ ?', parent.path)
  end

  def user_activities
    activity_base.where(owner_id: parent.profile.id)
  end

  class << self
    def class_key
      @class_key ||=
        Edge.descendants.select { |k| k.include?(Edgeable::Content) }.map { |k| k.name.underscore }.join('|')
    end

    def requested_index_resource(params, user_context)
      parent = LinkedRails.iri_mapper.parent_from_params(params, user_context)
      return unless parent&.enhanced_with?(Feedable)

      feed = Feed.new(parent: parent)

      feed.activity_collection(index_collection_params(params, user_context))
    end
  end
end
