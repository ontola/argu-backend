class NotificationPolicy < RestrictivePolicy
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
      scope.where(profile_id: user.profile.id)
    end
  end

  def initialize(context, record)
    super(context, record)
    raise Argu::NotLoggedInError.new(nil, record), 'must be logged in' unless user
  end

  def index?
    user.present?
  end

  def update?
    user.profile == record.profile
  end

  def permitted_attributes
    attributes = super
    attributes
  end

end
