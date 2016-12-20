# frozen_string_literal: true
class ActivityPolicy < RestrictivePolicy
  class Scope < EdgeTreePolicy::Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context

    def resolve
      return scope if staff?
      activities = Activity.arel_table
      profiles = Profile.arel_table
      scope
        .published_for_user(user)
        .joins(:forum)
        .where("#{class_name.tableize}.forum_id IN (?) OR forums.visibility = ?",
               forum_ids_by_access_tokens.concat(user&.profile&.forum_ids || []),
               Forum.visibilities[:open])
        .joins(:owner)
        .where(activities[:key].not_eq('vote.create').or(
                 profiles[:are_votes_public].eq(true)
        ))
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
