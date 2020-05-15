# frozen_string_literal: true

class GrantTree
  class PermissionSerializer < BaseSerializer
    PermittedAction::ACTIONS.each do |action|
      attribute action, predicate: NS::ARGU["#{action}Permission"]
      attribute "#{action}_tooltip", predicate: NS::ARGU["#{action}PermissionTooltip"]

      attribute "#{action}_icon", predicate: NS::ARGU["#{action}PermissionIcon"] do |object|
        serialize_image(object.send("#{action}_icon"))
      end
    end
  end
end
