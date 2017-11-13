# frozen_string_literal: true

class FavoritePolicy < EdgeTreePolicy
  delegate :show?, to: :edgeable_policy

  def create?
    edgeable_policy.show?
  end

  def destroy?
    rule is_creator?
  end

  private

  def edgeable_record
    @edgeable_record ||= record.edge.owner
  end

  def is_creator?
    creator if record.user == user
  end
end
