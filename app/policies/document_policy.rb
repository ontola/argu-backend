class DocumentPolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end

  end

  ######CRUD######
  def show?
    true
  end

  def new?
    create?
  end

  def create?
    super
  end

  def edit?
    update?
  end

  def update?
    super
  end

end
