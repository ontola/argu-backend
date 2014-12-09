class DocumentPolicy < ApplicationPolicy
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
    staff?
  end

  def edit?
    update?
  end

  def update?
    staff?
  end

end
