class OrganisationPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end

  end

  ######CRUD######
  def show?
    puts "=================#{Organisation.public_forms[record.public_form]} == #{Organisation.public_forms[:f_public]}====================="
    Organisation.public_forms[record.public_form] == Organisation.public_forms[:f_public] || (user && user.memberships.where(organisation: record).present?) || super
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
    (user && user.memberships.where(organisation: record, role: Membership.roles[:manager]).present?) || super
  end

  #######Attributes########
  # Is the current user a member of the group?
  def member?
    (user && user.memberships.where(organisation: record).present?) || staff?
  end

  # Can the current user change the organisation web_url? (currently a subdomain)
  def web_url?
    (user && user.memberships.where(organisation: record, role: Membership.roles[:manager]).present?) || staff?
  end

end
