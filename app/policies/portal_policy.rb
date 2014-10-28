class PortalPolicy < Struct.new(:user, :portal)
  class Scope
    def resolve
      scope
    end
  end

  def home?
    user.profile.has_role? :staff
  end
end
