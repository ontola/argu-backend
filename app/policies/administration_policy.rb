class AdministrationPolicy < Struct.new(:user, :administration)
  class Scope
    def resolve
      scope
    end
  end

  def show?
    true
  end

  def list?
    true
  end
end
