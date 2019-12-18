class AddIncidentAndScenarioGrants < ActiveRecord::Migration[5.2]
  def change
    PermittedAction.create_for_grant_sets('Incident', 'show', GrantSet.reserved)
    PermittedAction.create_for_grant_sets('Incident', 'create', GrantSet.reserved(only: %w[moderator administrator staff]))
    PermittedAction.create_for_grant_sets('Incident', 'update', GrantSet.reserved(only: %w[moderator administrator staff]))
    PermittedAction.create_for_grant_sets('Incident', 'trash', GrantSet.reserved(only: %w[moderator administrator staff]))
    PermittedAction.create_for_grant_sets('Incident', 'destroy', GrantSet.reserved(only: %w[moderator administrator staff]))
    PermittedAction.create_for_grant_sets('Scenario', 'show', GrantSet.reserved)
    PermittedAction.create_for_grant_sets('Scenario', 'create', GrantSet.reserved(only: %w[moderator administrator staff]))
    PermittedAction.create_for_grant_sets('Scenario', 'update', GrantSet.reserved(only: %w[moderator administrator staff]))
    PermittedAction.create_for_grant_sets('Scenario', 'trash', GrantSet.reserved(only: %w[moderator administrator staff]))
    PermittedAction.create_for_grant_sets('Scenario', 'destroy', GrantSet.reserved(only: %w[moderator administrator staff]))
  end
end
