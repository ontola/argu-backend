# frozen_string_literal: true

class CustomMenuItemPolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      return scope.none if user.nil?

      @scope.select(&method(:allowed_menu_item))
    end

    private

    def allowed_menu_item(menu_item)
      resource = menu_item.edge || menu_item.resource
      Pundit.policy(context, resource).send(menu_item.policy || :show?)
    rescue ActiveRecord::RecordNotFound
      false
    end
  end

  permit_attributes %i[raw_label raw_href icon order edge edge_id custom_image custom_image_content_type target_type]

  def show?
    true
  end

  def create?
    return false unless administrator? || staff?
    return forbid_wrong_tier unless feature_enabled?(:custom_menu_items)

    true
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
