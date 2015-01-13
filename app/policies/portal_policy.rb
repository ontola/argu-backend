class PortalPolicy < Struct.new(:user, :portal)
  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @record = record
  end

  def home?
    @user && @user.profile.has_role?(:staff)
  end

  class Scope
    def resolve
      scope
    end
  end
end
