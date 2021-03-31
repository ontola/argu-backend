# frozen_string_literal: true

class CartDetailPolicy < EdgePolicy
  def create?
    return if CartDetail.where_with_redis(publisher: user, parent: record.parent).any?
    return if record.shop.cart_for(user).submitted?

    super
  end

  def show?
    return false if record.parent.nil?

    parent_policy.show?
  end

  def destroy?
    super if CartDetail.where_with_redis(publisher: user, parent: record.parent).any?
  end
end
