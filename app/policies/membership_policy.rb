class MembershipPolicy < RestrictivePolicy
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

  # #####CRUD######
  def show?
    super
  end

  def new?
    create?
  end

  def create?
    # TODO: when implementing forum scopes, change this to include whether membership isn't restricted
    if record.role == :member.to_s
      rule is_open?, has_access_token?, is_member?, is_manager?, super
    elsif record.role == :manager.to_s
      rule is_manager?, is_owner?, super
    end
  end

  def edit?
    update?
  end

  def update?
    super
  end

  def destroy?
    actor &&
      (record.profile == actor || (forum_policy.update? || staff?) &&
      record.forum.memberships.where(role: Membership.roles[:manager]).where.not(id: record.id).present?)
  end

  private

  def forum_policy
    ForumPolicy.new(context, record.forum)
  end
end
