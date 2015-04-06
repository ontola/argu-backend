class ProfilePolicy < RestrictivePolicy
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
      raise Pundit::NotAuthorizedError, 'must be logged in' unless user
      scope.where(is_public: true)
    end
  end

  def initialize(context, record)
    @context = context
    @record = record

    # Note: Needs to be overridden since RestrictivePolicy checks for
    #       record-level access
    unless has_access_to_platform?
      raise Argu::NotLoggedInError.new(nil, record), 'must be logged in'
    end
  end

  def index
    is_owner? || staff?
  end

  def show?
    if record.profileable.class == Page
      record.is_public?
    else
      record.profileable.finished_intro? || super
    end
  end

  def update?
    record.profileable == user || super
  end

  def edit?
    update?
  end
end
