class ArgumentPolicy < RestrictivePolicy
  include ForumPolicy::ForumRoles

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
      scope
    end
  end

  def permitted_attributes
    attributes = super
    attributes << [:title, :content, :pro, :motion_id, :forum_id] if create?
    attributes
  end

  def new?
    rule is_open?, is_member?, is_manager?, is_owner?, super
  end

  def create?
    rule is_member?, is_manager?, is_owner?, super
  end

  def update?
    rule (is_member? && is_creator?), is_manager?, is_owner?, super
  end

  def edit?
    update?
  end

  def trash?
    rule is_creator?, is_manager?, is_owner?, super
  end

  def destroy?
    creator = 1.hour.ago <= record.created_at ? is_creator? : nil
    rule creator, is_manager?, is_owner?, super
  end

  def show?
    if record.motion.project.present?
      rule Pundit.policy(context, record.motion.project).show?, super
    else
      rule is_open?, has_access_token?, is_member?, is_manager?, is_owner?, super
    end
  end
end
