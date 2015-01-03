class PagePolicy < RestrictivePolicy
  class Scope < Scope
    def resolve
      scope
    end

  end

  def permitted_attributes
    attributes = super
    attributes << [:bio, :tag_list, {profile_attributes: [:id, :name, :profile_photo]}] if update?
    attributes << :page_id if change_owner?
    attributes
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

  def statistics?
    false
  end

end
