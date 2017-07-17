# frozen_string_literal: true
class ActivityPolicy < RestrictivePolicy
  class Scope < EdgeTreePolicy::Scope
    def resolve
      return @scope if staff?
      s = filter_unpublished_and_unmanaged(@scope)
      s = filter_inaccessible_forums(s)
      filter_private_votes(s)
    end

    private

    # Trackable should be placed in one of the forums available to the current user
    def filter_inaccessible_forums(scope)
      scope
        .joins(:trackable_edge)
        .where("edges.path ? #{Edge.path_array(user.profile.granted_edges)}")
    end

    # If trackable is a vote, its profile should have public votes
    def filter_private_votes(scope)
      activities = Activity.arel_table
      profiles = Profile.arel_table
      scope
        .joins(:owner)
        .where(activities[:key].not_eq('vote.create').or(
                 profiles[:are_votes_public].eq(true)
        ))
    end

    # Trackable should be published OR be created by one of the managed profiles OR be placed in a managed forum
    def filter_unpublished_and_unmanaged(scope)
      scope
        .joins(:trackable_edge)
        .where('edges.is_published = true OR activities.owner_id IN (:profile_ids) OR edges.path ? '\
               "#{Edge.path_array(user.profile.granted_edges(nil, :manager))}",
               profile_ids: user.managed_profile_ids)
    end
  end

  def show?
    Pundit.policy(context, record.trackable)
  end

  def permitted_attributes
    attributes = super
    attributes
  end
end
