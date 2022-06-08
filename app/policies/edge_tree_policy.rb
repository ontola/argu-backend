# frozen_string_literal: true

class EdgeTreePolicy < RestrictivePolicy
  class Scope < RestrictivePolicy::Scope
    include UUIDHelper

    def grant_tree
      @grant_tree ||= context.grant_tree_for(context.tree_root)
    end

    def staff?
      grant_tree
        .grant_sets(grant_tree.tree_root, group_ids: user.profile.group_ids)
        .map(&:title)
        .include?('staff')
    end

    private

    %i[edges grant_sets grant_sets_permitted_actions granted_paths grants
       groups group_memberships managed_forum_paths permitted_actions widgets].each do |table_name|
      define_method "#{table_name}_table" do
        instance_variable_get(:"@#{table_name}_table") ||
          instance_variable_set(:"@#{table_name}_table", Arel::Table.new(table_name))
      end
    end

    def active_group_memberships_filter # rubocop:disable Metrics/AbcSize
      groups_table[:id]
        .eq(group_memberships_table[:group_id])
        .and(group_memberships_table[:start_date].lteq(Arel::Nodes::NamedFunction.new('STATEMENT_TIMESTAMP', [])))
        .and(
          group_memberships_table[:end_date].eq(nil)
            .or(group_memberships_table[:end_date].gteq(Arel::Nodes::NamedFunction.new('STATEMENT_TIMESTAMP', [])))
        )
    end

    def active_or_creator
      edges_table[:is_published].eq(true).or(edges_table[:creator_id].in(managed_profile_ids))
    end

    def filtered_edge_table
      table = joined_edge_table.where(group_memberships_table[:member_id].eq(user.profile.id))
      return table unless grant_tree&.tree_root_id

      table
        .where(edges_table[:root_id].eq(grant_tree.tree_root_id))
    end

    def granted_path_action_join(table)
      table
        .join(granted_paths_table)
        .on(
          granted_paths_table[:id].eq(table[:permitted_action_id])
            .and(granted_paths_table[:paths].contains(Edge.arel_table[:path]))
        ).join_sources.first.to_sql
    end

    def granted_path_type_join(table = Arel::Table.new(:parents_edges)) # rubocop:disable Metrics/AbcSize
      table
        .join(granted_paths_table)
        .on(
          granted_paths_table[:resource_type].eq(edges_table[:owner_type])
            .and(
              granted_paths_table[:parent_type].eq(table[:owner_type])
                .or(granted_paths_table[:parent_type].eq('*'))
            ).and(granted_paths_table[:paths]).contains(edges_table[:path])
        ).join_sources.first.to_sql
    end

    def granted_paths(show_only: true)
      @granted_paths ||=
        Arel::Nodes::As.new(
          granted_paths_table,
          granted_paths_base(show_only: show_only)
            .project(
              'array_agg(path) AS paths, permitted_actions.resource_type AS resource_type, '\
              'permitted_actions.parent_type AS parent_type, permitted_actions.id AS id'
            )
        )
    end

    def granted_paths_base(show_only:)
      return filtered_edge_table unless show_only

      filtered_edge_table.where(permitted_actions_table[:action_name].eq(PermittedAction.action_names[:show]))
    end

    def joined_edge_table # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      edges_table
        .join(grants_table).on(edges_table[:uuid].eq(grants_table[:edge_id]))
        .join(grant_sets_table).on(grant_sets_table[:id].eq(grants_table[:grant_set_id]))
        .join(grant_sets_permitted_actions_table)
        .on(grant_sets_table[:id].eq(grant_sets_permitted_actions_table[:grant_set_id]))
        .join(groups_table).on(groups_table[:id].eq(grants_table[:group_id]))
        .join(group_memberships_table)
        .on(active_group_memberships_filter)
        .join(permitted_actions_table)
        .on(permitted_actions_table[:id].eq(grant_sets_permitted_actions_table[:permitted_action_id]))
        .group(
          permitted_actions_table[:resource_type],
          permitted_actions_table[:parent_type],
          permitted_actions_table[:id]
        )
    end

    def managed_forum_paths
      @managed_forum_paths ||=
        Arel::Nodes::As.new(
          managed_forum_paths_table,
          filtered_edge_table
            .where(permitted_actions_table[:action_name].eq(PermittedAction.action_names[:update]))
            .where(permitted_actions_table[:resource_type].eq('Forum'))
            .project('path')
        )
    end
  end
  delegate :has_expired_ancestors?, :has_trashed_ancestors?, :has_unpublished_ancestors?, :has_grant_set?,
           :persisted_edge, :spectator?, :participator?, :moderator?, :administrator?, :staff?, to: :edgeable_policy

  def grant_tree
    @grant_tree ||= context.grant_tree_for(edgeable_record)
  end

  def granted_group_ids(action_name)
    edgeable_policy.try(:granted_group_ids, action_name) if record.try(:edgeable_record)
  end

  def public_resource?
    granted_group_ids(:show).include?(Group::PUBLIC_ID)
  end

  private

  def edgeable_policy
    @edgeable_policy ||= Pundit.policy(context, edgeable_record)
  end

  def edgeable_record
    record.try(:edgeable_record) || raise(ActiveRecord::RecordNotFound.new('No edgeable record avaliable in policy'))
  end
end
