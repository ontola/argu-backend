class PortalPolicy < Struct.new(:user, :portal)
  attr_reader :context, :record, :last_verdict, :last_enacted

  def initialize(context, record)
    #raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @context = context
    @record = record
  end

  delegate :user, to: :context
  delegate :session, to: :context

  def home?
    user && user.profile.has_role?(:staff)
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
