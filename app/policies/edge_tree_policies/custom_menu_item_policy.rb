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

  permit_attributes %i[raw_label label_translation raw_image order]
  permit_attributes %i[raw_href], has_properties: {edge_id: false}

  def update?
    staff?
  end

  def destroy?
    staff?
  end
end
