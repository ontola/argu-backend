class PortalPolicy < Struct.new(:user, :portal)
  attr_reader :context, :user, :record, :session

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
    def resolve
      scope
    end
  end
end
