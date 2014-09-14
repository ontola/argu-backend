class RestrictivePolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user && user.has_role?(:staff)
  end

  def show?
    user && user.has_role?(:staff)
  end

  def create?
    user && user.has_role?(:staff)
  end

  def new?
    create?
  end

  def update?
    user && user.has_role?(:staff)
  end

  def edit?
    update?
  end

  def trash?
    user && user.has_role?(:staff)
  end

  def destroy?
    user && user.has_role?(:staff)
  end

  def vote?
    user && user.has_role?(:staff)
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end
end

