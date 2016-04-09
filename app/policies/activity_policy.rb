class ActivityPolicy < RestrictivePolicy
  class Scope < Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
    delegate :session, to: :context

    def resolve
      activities = Activity.arel_table
      profiles = Profile.arel_table
      scope
        .where(['forum_id IN (%s)', context.context_model.try(:id) || user.try(:profile).try(:memberships_ids) || 'NULL'])
        .joins(:owner)
        .where(activities[:key].not_eq('vote.create').or(
                 profiles[:are_votes_public].eq(true)))
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
