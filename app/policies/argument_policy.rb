class ArgumentPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def permitted_attributes
    attributes = super
    attributes << [:title, :content, :pro, :motion_id, :forum_id] if create?
    attributes
  end

  def new?
    record.forum.open? || create?
  end

  def create?
    is_member? || super
  end

  def update?
    is_member? && is_creator? || super
  end

  def edit?
    update?
  end

  def show?
    Pundit.policy(context, record.forum).show? || super
  end

  private

  def is_member?
    user && user.profile.member_of?(record.motion.forum)
  end
end
