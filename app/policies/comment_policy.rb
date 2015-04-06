class CommentPolicy < RestrictivePolicy
  class Scope < Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
    delegate :session, to: :context

    def resolve
      scope
    end
  end

  def create?
    record.commentable.forum.open? || is_member? || super
  end

  def destroy?
    user && record.profile_id == actor.id || is_owner? || super
  end

  def edit?
    update?
  end

  def new?
    record.forum.open? || create?
  end

  def report?
    true
  end

  def show?
    Pundit.policy(context, record.forum).show? || super
  end

  def trash?
    is_manager? || is_owner? || super
  end

  def update?
    is_member? && is_creator? || super
  end

  def has_access_to_platform?
    user || has_access_token_access_to(record.commentable.forum)
  end

private

  def is_manager?
    Pundit.policy(context, record.forum).is_manager?
  end

  def is_member?
    user && user.profile.member_of?(record.commentable.forum)
  end

  def is_owner?
    Pundit.policy(context, record.forum).is_owner?
  end
end
