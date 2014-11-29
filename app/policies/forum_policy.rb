class ForumPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end

  end

  def permitted_attributes
    attributes = []
    attributes << [:name, :bio, :tag_list] if update?
    attributes << :page_id if change_owner?
    attributes << :web_url if web_url?
    attributes
  end

  ######CRUD######
  def show?
    #(user && user.profile.memberships.where(forum: record).present?) || super
    true || super # Until forum scope settings are implemented
  end

  def show_children?
    member? || staff?
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

  def change_owner?
    staff?
  end

  #######Attributes########
  # Is the current user a member of the group?
  def member?
    (user && user.profile.memberships.where(forum: record).present?) || staff?
  end

end
