# frozen_string_literal: true

class CartDetailPolicy < EdgePolicy
  delegate :show?, to: :parent_policy

  def create?
    return if CartDetail.where_with_redis(publisher: user, parent: record.parent).any?

    super
  end

  def destroy?
    super if CartDetail.where_with_redis(publisher: user, parent: record.parent).any?
  end
end
