class NotificationPolicy < RestrictivePolicy
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
      if user
        scope.where(user_id: user.id)
      else
        scope.where(false)
      end
    end
  end

  def initialize(context, record)
    super(context, record)
    raise Argu::NotLoggedInError.new(nil, record), 'must be logged in' unless user
  end

  def permitted_attributes
    attributes = super
    attributes << [:user_id, :title, :url] if staff?
    attributes
  end

  def index?
    user.present?
  end

  def read?
    user.present?
  end

  def create?
    staff?
  end

  def update?
    user && user == record.user
  end

end
