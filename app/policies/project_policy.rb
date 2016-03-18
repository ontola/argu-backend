class ProjectPolicy < RestrictivePolicy
  include ForumPolicy::ForumRoles

  class Scope < RestrictivePolicy::Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
    delegate :session, to: :context

    def resolve
      scope
    end
  end

  def permitted_attributes
    attributes = super
    attributes << %i(id title content start_date end_date email) if create?
    phase = record.is_a?(Project) && Phase.new(project: record, forum: record.forum)
    attributes << {phases_attributes: Pundit.policy(context, phase).permitted_attributes} if phase && create?
    stepup = record.is_a?(Project) && Stepup.new(record: record, forum: record.forum)
    attributes << {stepups_attributes: Pundit.policy(context, stepup).permitted_attributes(true)} if stepup && (record.try(:new_record?) || is_manager_up?)
    attributes << %i(id title content start_date end_date achieved_end_date email publish unpublish) if update?
    attributes
  end

  def create?
    rule is_moderator?, is_manager?, is_owner?, super
  end

  def destroy?
    user && (record.creator_id == user.profile.id && 15.minutes.ago < record.created_at) || is_manager? || is_owner? || super
  end

  def edit?
    rule update?
  end

  def list?
    if record.is_published? && !record.is_trashed?
      rule is_open?, has_access_token?, is_member?, is_manager?, is_owner?, super
    else
      rule is_moderator?, is_manager?, is_owner?, super
    end
  end

  def new?
    rule is_moderator?, is_manager?, is_owner?, super
  end

  def show?
    if record.is_published? && !record.is_trashed?
      rule is_open?, has_access_token?, is_member?, is_manager?, is_owner?, super
    else
      rule is_moderator?, is_manager?, is_owner?, super
    end
  end

  def trash?
    rule is_moderator?, is_creator?, is_manager?, is_owner?, super
  end

  def update?
    rule is_moderator?, is_manager?, is_owner?, super
  end

  private

  def forum_policy
    Pundit.policy(context, record.try(:forum) || context.context_model)
  end
end
