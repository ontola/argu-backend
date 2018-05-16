# frozen_string_literal: true

class FavoritePolicy < EdgeTreePolicy
  delegate :show?, to: :edgeable_policy

  def create?
    edgeable_policy.show?
  end

  def destroy?
    is_creator?
  end

  private

  def is_creator?
    record.user == user
  end
end
