# frozen_string_literal: true

class CustomMenuItemPolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      @scope.select { |menu_item| menu_item.edge.nil? || Pundit.policy(context, menu_item.edge).show? }
    end
  end
end
