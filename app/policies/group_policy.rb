class GroupPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end

  end

  ######CRUD######
  def show?
    Group.public_forms[record.public_form] == Group.public_forms[:f_public] || (user && user.profile.group_memberships.where(group: record).present?) || super
  end

  def new?
    create?
  end

  def create?
    user || super
  end

  def edit?
    update?
  end

  def update?
    (user && user.profile.group_memberships.where(group: record, role: GroupMembership.roles[:manager]).present?) || super
  end

  #######Attributes########
  # Is the current user a member of the group?
  def member?
    (user && user.profile.group_memberships.where(group: record).present?) || staff?
  end

  # Can the current user change the organisation web_url? (currently a subdomain)
  def web_url?
    (user && user.profile.group_memberships.where(group: record, role: GroupMembership.roles[:manager]).present?) || staff?
  end

end
