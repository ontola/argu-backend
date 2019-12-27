# frozen_string_literal: true

class CustomMenuItemPolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
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

  def permitted_attribute_names
    attrs = %i[raw_label label_translation raw_image order]
    attrs.append(:raw_href) if record.edge_id.blank?
    attrs
  end

  def update?
    staff?
  end

  def destroy?
    staff?
  end
end
