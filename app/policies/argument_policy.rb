class ArgumentPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def permitted_attributes
    attributes = super
    attributes << [:title, :content, :pro, :motion_id] if create?
  end

  def create?
    is_member? || super
  end

  def show?
    is_member? || super
  end

  private

  def is_member?
    user.profile.member_of? record.motion.forum
  end
end
