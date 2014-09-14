class OrganisationPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end

  end

  def show?
    (user && user.memberships.where(organisation: record).present?) || super
  end

  def new?
    create?
  end

  def create?
    user.has_role? :staff
  end

  def edit?
    update?
  end

  def update?
    user.has_role :staff
  end
end
