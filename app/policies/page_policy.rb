class PagePolicy < RestrictivePolicy
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

  def add_question?
    false || update?
  end

  #######Attributes########
  # Can the current user change the forum web_url? (currently a subdomain)
  def web_url?
    (user && user.profile.memberships.where(forum: record, role: Membership.roles[:manager]).present?) || staff?
  end

end
