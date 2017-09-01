# frozen_string_literal: true

class LinkedRecordPolicy < EdgeablePolicy
  def show?
    rule is_spectator?, is_member?, is_manager?, is_super_admin?, super
  end

  def create?
    false
  end

  def update?
    false
  end

  def trash?
    false
  end

  def untrash?
    false
  end

  def destroy?
    false
  end
end
