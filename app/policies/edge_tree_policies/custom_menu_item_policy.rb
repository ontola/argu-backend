# frozen_string_literal: true

class CustomMenuItemPolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      @scope.select { |menu_item| menu_item.edge.nil? || Pundit.policy(context, menu_item.edge).show? }
    end
  end

  def permitted_attribute_names
    %i[raw_label label_translation raw_href raw_image order]
  end

  def update?
    staff?
  end

  def destroy?
    staff?
  end
end
