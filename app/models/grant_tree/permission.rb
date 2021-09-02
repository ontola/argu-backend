# frozen_string_literal: true

class GrantTree
  class Permission
    include ActiveModel::Model
    include LinkedRails::Model

    attr_accessor :node, :permission_group, :resource_type

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
            .permitted_parent_types(action_name: action, group_id: permission_group.group_id, resource_type: resource_type)
            .map { |a| a == '*' ? NS.argu[:contentTreeClass] : a.constantize.iri }
        )
      end

      define_method "#{action}_icon" do
        return 'fa-close' if send(action).blank?

        send(action).include?(NS.argu[:contentTreeClass]) ? 'fa-check' : 'fa-question'
      end

      define_method "#{action}_tooltip" do
        return nil if send(action).blank? || send(action).include?(NS.argu[:contentTreeClass])

        send(action).map { |parent_type| parent_type.to_s.split('#').last.classify.constantize.plural_label }.join(', ')
      end
    end
  end
end
