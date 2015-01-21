class CommentPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end
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
    Pundit.policy(user, record.forum).show? || super
  end

  def report?
    true
  end

private

  def is_member?
    user.profile.member_of? record.commentable.forum
  end
end
