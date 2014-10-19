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
    super
  end

  def edit?
    update?
  end

  def update?
    super
  end

  def destroy?
    (OrganisationPolicy.new(user, record.organisation).update? || staff?) && record.organisation.memberships.where(role: Membership.roles[:manager]).where.not(id: record.id).present?
  end

end
