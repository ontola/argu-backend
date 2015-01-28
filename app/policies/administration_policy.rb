class AdministrationPolicy < Struct.new(:user, :administration)
  class Scope
    def resolve
      scope
    end
  end

  def show?
    user.has_role? :staff
  end

  def list?
    user.has_role? :staff
  end
end
