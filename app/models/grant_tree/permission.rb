# frozen_string_literal: true

class GrantTree
  class Permission
    include ActiveModel::Model
    include Iriable

    attr_accessor :node, :permission_group, :resource_type
    alias read_attribute_for_serialization send

    def initialize(permission_group, node, resource_type)
      self.permission_group = permission_group
      self.node = node
      self.resource_type = resource_type
    end

    def iri_opts
      {group_id: permission_group.group_id, edge_id: node.id, resource_type: resource_type}
    end

    PermittedAction::ACTIONS.each do |action|
      define_method action do
        return instance_variable_get("@#{action}") if instance_variable_defined?("@#{action}")
        instance_variable_set(
          "@#{action}",
          node
            .permitted_parent_types(action: action, group_id: permission_group.group_id, resource_type: resource_type)
            .map { |a| a == '*' ? NS::ARGU[:contentTreeClass] : a.constantize.iri }
        )
      end

      define_method "#{action}_icon" do
        return 'fa-close' if send(action).blank?
        send(action).include?(NS::ARGU[:contentTreeClass]) ? 'fa-check' : 'fa-question'
      end

      define_method "#{action}_tooltip" do
        return nil if send(action).blank? || send(action).include?(NS::ARGU[:contentTreeClass])
        send(action).map { |parent_type| I18n.t("#{parent_type.to_s.split('#').last.tableize}.plural") }.join(', ')
      end
    end
  end
end
