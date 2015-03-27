class CommentPolicy < RestrictivePolicy
  class Scope < Scope
    attr_reader :context, :user, :scope, :session

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

  def initialize(context, record)
    @context = context
    @record = record
    unless has_access_to_platform?
      raise Argu::NotLoggedInError.new(nil, record), 'must be logged in'
    end
  end

  def new?
    record.forum.open? || create?
  end

  def create?
    record.commentable.forum.open? || is_member? || super
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

  def report?
    true
  end

  def has_access_to_platform?
    user || has_access_token_access_to(record.commentable.forum)
  end

private

  def is_member?
    user && user.profile.member_of?(record.commentable.forum)
  end
end
