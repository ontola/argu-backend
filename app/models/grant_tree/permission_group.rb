# frozen_string_literal: true

class GrantTree
  class PermissionGroup
    include ActiveModel::Model
    include LinkedRails::Model
    include URITemplateHelper

    attr_accessor :node, :group_id

    delegate :edgeable_record, to: :node
    with_collection :permissions,
                    association_class: GrantTree::Permission,
                    policy_scope: false
    with_columns(
      default: [
        NS.argu[:group],
        NS.argu[:showPermission],
        NS.argu[:updatePermission],
        NS.argu[:trashPermission],
        NS.argu[:destroyPermission]
      ],
      settings: [NS.argu[:group]] + GrantReset.resource_types.keys.map do |type|
        NS.argu["create#{type}Permission"]
      end
    )
    delegate(*GrantReset.action_names.keys.map(&:to_sym), to: :node_permission, allow_nil: true)

    def initialize(group_id: nil, node: nil)
      self.group_id = group_id&.to_i
      self.node = node
    end

    def group
      @group ||= Group.find(group_id)
    end

    def iri_opts
      {
        id: group_id,
        parent_iri: split_iri_segments(edgeable_record&.root_relative_iri)
      }
    end

    def node_permission
      @node_permission ||= permission_for_type(edgeable_record.class.name)
    end

    def permissions
      GrantReset.resource_types.keys.map do |permission|
        Permission.new(permission_group: self, node: node, resource_type: permission)
      end
    end

    GrantReset.resource_types.except.keys.map do |type|
      define_method "create_#{type.underscore}" do
        permission = permission_for_type(type)
        permission.create
      end
    end

    def grant_sets
      @grant_sets ||= node.grant_sets[group_id]
    end

    private

    def permission_for_type(type)
      permissions.detect do |permission|
        permission.resource_type == type
      end
    end

    class << self
      def attributes_for_new(**opts)
        {
          group_id: Group::PUBLIC_ID,
          node: opts[:parent]
        }
      end

      def iri_template
        @iri_template ||= LinkedRails::URITemplate.new("{/parent_iri*}/#{route_key}{/id}{#fragment}")
      end

      def requested_single_resource(params, user_context)
        parent = LinkedRails.iri_mapper.parent_from_params(params, user_context)
        return unless parent

        node = parent.is_a?(GrantTree::Node) ? parent : user_context.grant_tree.find_or_cache_node(parent)

        new(group_id: params[:id], node: node)
      end
    end
  end
end
