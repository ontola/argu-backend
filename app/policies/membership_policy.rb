class MembershipPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end

  end

  ######CRUD######
  def show?
    super
  end

  def new?
    create?
  end

  def create?
    # TODO: when implementing forum scopes, change this to include whether membership isn't restricted
    record.role == :member.to_s || super
  end

  def edit?
    update?
  end

  def update?
    super
  end

  def destroy?
    (ForumPolicy.new(user, record.forum).update? || staff?) && record.forum.memberships.where(role: Membership.roles[:manager]).where.not(id: record.id).present?
  end

end
