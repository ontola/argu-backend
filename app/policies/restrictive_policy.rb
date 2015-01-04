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
    attributes << :is_trashed if trash?
    attributes
  end

  def staff?
    user && user.profile.has_role?(:staff)
  end

  def change_owner?
    staff?
  end

  def create?
    staff?
  end

  def destroy?
    staff?
  end

  def edit?
    update?
  end

  def index?
    staff?
  end

  def logged_in?
    user.present?
  end

  def new?
    create?
  end

  def show?
    staff?
  end

  def statistics?
    staff?
  end

  def trash?
    staff?
  end

  def update?
    staff?
  end

  def vote?
    staff?
  end

  # Can the current user change the forum web_url? (currently a subdomain)
  def web_url?
    staff?
  end

  def is_creator?
    creator = record.creator
    profile = user.profile
    record.creator == user.profile
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @profile = user.profile
      @scope = scope
    end

    def resolve
      scope if staff?
    end

    def staff?
      user && @profile.has_role?(:staff)
    end
  end

end

