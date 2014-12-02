class PagePolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end

  end

  def permitted_attributes
    attributes = super
    attributes << [:name, :bio, :tag_list] if update?
    attributes << :page_id if change_owner?
  end

  ######CRUD######
  def show?
    super
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

  def add_question?
    false || update?
  end

end
