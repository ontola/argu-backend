# frozen_string_literal: true

class CustomMenuItemPolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      @scope.select { |menu_item| menu_item.edge.nil? || Pundit.policy(context, menu_item.edge).show? }
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
