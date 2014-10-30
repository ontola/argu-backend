class OrganisationPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end

  end

  ######CRUD######
  def show?
    Organisation.public_forms[record.public_form] == Organisation.public_forms[:f_public] || (user && user.profile.memberships.where(organisation: record).present?) || super
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
    (user && user.profile.memberships.where(organisation: record, role: Membership.roles[:manager]).present?) || super
  end

  def add_question?
    false || update?
  end

  #######Attributes########
  # Is the current user a member of the group?
  def member?
    (user && user.profile.memberships.where(organisation: record).present?) || staff?
  end

  # Can the current user change the organisation web_url? (currently a subdomain)
  def web_url?
    (user && user.profile.memberships.where(organisation: record, role: Membership.roles[:manager]).present?) || staff?
  end

end
