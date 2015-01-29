class ApplicationPolicy
  attr_reader :context, :user, :record, :session

  def initialize(context, record)
    #raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @context = context
    @record = record
  end

  delegate :user, to: :context
  delegate :session, to: :context

  def staff?
    user && user.profile.has_role?(:staff)
  end

  def index?
    @user
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    user
  end

  def new?
    create?
  end

  def update?
    user
  end

  def edit?
    update?
  end

  def trash?
    !record.is_trashed && user
  end

  def destroy?
    user
  end

  def vote?
    user
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
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
end

