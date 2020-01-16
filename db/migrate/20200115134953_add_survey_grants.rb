class AddSurveyGrants < ActiveRecord::Migration[5.2]
  def change
    PermittedAction.create_for_grant_sets('Survey', 'show', GrantSet.reserved)
    PermittedAction.create_for_grant_sets('Survey', 'update', GrantSet.reserved(only: %w[administrator staff]))
    PermittedAction.create_for_grant_sets('Survey', 'destroy', GrantSet.reserved(only: %w[administrator staff]))
    PermittedAction.create_for_grant_sets('Survey', 'create', GrantSet.reserved(only: %w[staff]))
  end
end
