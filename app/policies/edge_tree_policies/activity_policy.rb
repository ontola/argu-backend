# frozen_string_literal: true

class ActivityPolicy < RestrictivePolicy
  class Scope < EdgeTreePolicy::Scope
    def resolve
      @scope = @scope.where(root_id: grant_tree.tree_root_id) if grant_tree&.tree_root_id&.present?
      return @scope if staff?
      s = filter_unpublished_and_unmanaged(@scope)
      s = filter_inaccessible_forums(s)
      filter_private_votes(s)
    end

    private

    # Trackable should be placed in one of the forums available to the current user
    def filter_inaccessible_forums(scope)
      scope
        .joins(:trackable, :recipient)
        .with(granted_paths)
        .where(granted_path_type_filter(:recipients_activities))
    end

    # If trackable is a vote, its profile should have public votes
    def filter_private_votes(scope)
      activities = Activity.arel_table
      profiles = Profile.arel_table
      scope
        .joins('INNER JOIN "profiles" ON "profiles"."id" = "activities"."owner_id"')
        .where(activities[:key].not_eq('vote.create').or(
                 profiles[:are_votes_public].eq(true)
        ))
    end

    # Trackable should be published OR be created by one of the managed profiles OR be placed in a managed forum
    def filter_unpublished_and_unmanaged(scope)
      scope
        .joins(:trackable)
        .with(managed_forum_paths)
        .where(
          'edges.is_published = true OR activities.owner_id IN (:profile_ids) OR '\
          '(SELECT array_agg(path) FROM managed_forum_paths) @> edges.path',
          profile_ids: user.managed_profile_ids
        )
    end

    def staff?
      grant_tree.nil? ? user.is_staff? : super
    end
  end

  delegate :show?, to: :edgeable_policy

  def permitted_attribute_names
    attributes = super
    attributes << :comment
    attributes
  end
end
