# frozen_string_literal: true
module GroupsHelper
  def role_list(roles, edge)
    return t('roles.empty') if roles.empty?
    safe_join(
      roles
        .uniq { |role, _edge_id| role }
        .sort_by { |_role, edge_id| edge_id == edge.id ? 0 : 1 }
        .map(&(proc { |role, edge_id, grant_id| role_string(edge, role, edge_id, grant_id) })),
      ', '
    )
  end

  def role_string(edge, role, edge_id, grant_id)
    grant = Grant.find(grant_id)
    suffix = if edge_id == edge.id
               t('roles.list.remove_html', url: grant_path(grant))
             else
               t('roles.list.inherited_html',
                 url: url_for(grant.edge.owner),
                 inherited: t('grants.inherited', type: type_for(grant.edge.owner).downcase))
             end
    safe_join([t('roles.list.role_html', role: role, description: t("roles.types.#{role}")), suffix])
  end
end
