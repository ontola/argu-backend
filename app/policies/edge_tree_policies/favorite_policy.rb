# frozen_string_literal: true

class FavoritePolicy < EdgeTreePolicy
  def create?
    rule is_member?, is_manager?, is_super_admin?, super
  end

  def destroy?
    rule is_creator?
  end

  private

  def is_creator?
    creator if record.user == user
  end
end
