# frozen_string_literal: true

class GrantTree
  class PermissionSerializer < BaseSerializer
    PermittedAction::ACTIONS.each do |action|
      attribute action, predicate: NS.argu["#{action}Permission"]
      attribute "#{action}_tooltip", predicate: NS.argu["#{action}PermissionTooltip"]

      attribute "#{action}_icon", predicate: NS.argu["#{action}PermissionIcon"] do |object|
        serialize_image(object.send("#{action}_icon"))
      end
    end
  end
end
