class ForumPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end

  end

  ######CRUD######
  def show?
    (user && user.profile.memberships.where(forum: record).present?) || super
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
    (user && user.profile.memberships.where(forum: record, role: Membership.roles[:manager]).present?) || super
  end

  def add_question?
    false || update?
  end

  #######Attributes########
  # Is the current user a member of the group?
  def member?
    (user && user.profile.memberships.where(forum: record).present?) || staff?
  end

  # Can the current user change the forum web_url? (currently a subdomain)
  def web_url?
    (user && user.profile.memberships.where(forum: record, role: Membership.roles[:manager]).present?) || staff?
  end

end
