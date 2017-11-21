# frozen_string_literal: true

class GrantTree
  class PermissionSerializer < BaseSerializer
    PermittedAction::ACTIONS.each do |action|
      attribute action, predicate: NS::ARGU["#{action}Permission"]
      attribute "#{action}_tooltip", predicate: NS::ARGU["#{action}PermissionTooltip"]

      has_one "#{action}_icon", predicate: NS::ARGU["#{action}PermissionIcon"]

      define_method "#{action}_icon" do
        serialize_image(object.send("#{action}_icon"))
      end
    end
  end
end
