class AddProjectGrants < ActiveRecord::Migration[5.2]
  def change
    PermittedAction.create_for_grant_sets('Phase', 'show', GrantSet.reserved)
    PermittedAction.create_for_grant_sets('Project', 'show', GrantSet.reserved)
    PermittedAction.create_for_grant_sets('Project', 'update', GrantSet.reserved(only: %w[administrator staff]))
    PermittedAction.create_for_grant_sets('Project', 'destroy', GrantSet.reserved(only: %w[administrator staff]))
    PermittedAction.create_for_grant_sets('Project', 'create', GrantSet.reserved(only: %w[administrator staff]))
  end
end
