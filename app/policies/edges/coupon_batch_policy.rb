# frozen_string_literal: true

class CouponBatchPolicy < EdgePolicy
  permit_attributes %i[coupon_count display_name]

  class Scope < EdgeTreePolicy::Scope
    def resolve
      scope.active
    end
  end

  def show?
    parent_policy.update?
  end

  def create?
    parent_policy.update?
  end
end
