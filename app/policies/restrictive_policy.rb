class RestrictivePolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @record = record
  end

  def permitted_attributes
    attributes = []
    attributes << :web_url if web_url?
    attributes
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

  def logged_in?
    user.present?
  end

  def vote?
    staff?
  end

  # Can the current user change the forum web_url? (currently a subdomain)
  def web_url?
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

