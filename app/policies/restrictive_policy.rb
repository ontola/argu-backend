class RestrictivePolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def staff?
    user && user.profile.has_role?(:staff)
  end

  def index?
    staff?
  end

  def show?
    staff?
  end

  def create?
    staff?
  end

  def new?
    create?
  end

  def update?
    staff?
  end

  def edit?
    update?
  end

  def trash?
    staff?
  end

  def destroy?
    staff?
  end

  def vote?
    staff?
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

    #def current_scope
    #  current_scope if user.present?
    #end
  end

private
  #def current_scope
  #  user._current_scope if user.present?
  #end

end

