# frozen_string_literal: true

class CartDetailPolicy < EdgePolicy
  def create?
    return forbid_with_message(I18n.t('actions.cart_details.create.errors.already_added')) if already_added?

    super
  end

  def show?
    return forbid_with_message(I18n.t('actions.cart_details.show.errors.no_parent')) if record.parent.nil?

    parent_policy.show?
  end

  def destroy?
    super if CartDetail.where_with_redis(publisher: user, parent: record.parent).any?
  end

  private

  def already_added?
    CartDetail.where_with_redis(publisher: user, parent: record.parent).any?
  end
end
