# frozen_string_literal: true

module GroupsHelper
  def grant_edge_items(page)
    [[t('grants.all_forums'), page.id]].concat(page.forums.map { |f| [f.display_name, f.id] })
  end

  def custom_grant_props(resource, resource_type, action)
    {
      action: action,
      defaultGroupIds:
        user_context
          .grant_tree
          .granted_group_ids(
            resource.parent,
            action: 'create',
            resource_type: resource_type.classify,
            parent_type: resource.class.name
          ),
      grantsReset: resource.send("reset_#{action}_#{resource_type}"),
      groupIdsFieldName: "#{resource.class.name.underscore}[#{action}_#{resource_type}_group_ids][]",
      groups:
        user_context
          .grant_tree
          .granted_groups(resource.persisted_edge, resource_type: resource.class.name, action: 'show')
          .map { |group| {id: group.id, displayName: group.display_name} },
      resetFieldName: "#{resource.class.name.underscore}[reset_#{action}_#{resource_type}]",
      resourceType: resource_type.classify,
      selectedGroupIds: resource.send("#{action}_#{resource_type}_group_ids", user_context.grant_tree)
    }
  end
end
