# frozen_string_literal: true

class GrantTree
  class Permission
    include ActiveModel::Model
    include LinkedRails::Model
    include URITemplateHelper

    attr_accessor :node, :permission_group, :resource_type

    delegate :edgeable_record, to: :node

    def initialize(permission_group:, node:, resource_type:)
      self.permission_group = permission_group
      self.node = node
      self.resource_type = resource_type
    end

    def iri_opts
      {
        id: resource_type,
        parent_iri: split_iri_segments(permission_group&.root_relative_iri)
      }
    end

    def target_class
      @target_class ||= resource_type.constantize
    end

    GrantReset.action_names.each_key do |action|
      define_method action do
        return instance_variable_get("@#{action}") if instance_variable_defined?("@#{action}")

        instance_variable_set(
          "@#{action}",
          node
            .permitted_parent_types(
              action_name: action,
              group_id: permission_group.group_id,
              resource_type: resource_type
            ).map { |a| a == '*' ? NS.schema.Thing : a.constantize.iri }
        )
      end
    end

    class << self
      def attributes_for_new(*opts)
        {
          permission_group: opts[:parent],
          node: opts[:parent]&.node,
          resource_type: GrantReset.resource_types.keys.first
        }
      end

      def iri_template
        @iri_template ||= LinkedRails::URITemplate.new("{/parent_iri*}/#{route_key}{/id}{#fragment}")
      end

      def requested_single_resource(params, user_context)
        parent = LinkedRails.iri_mapper.parent_from_params(params, user_context)
        return unless parent

        new(
          permission_group: parent,
          node: parent.node,
          resource_type: params[:id]
        )
      end
    end
  end
end
