class CreateBannerGrants < ActiveRecord::Migration[6.0]
  def change
    PermittedAction.create_for_grant_sets('Banner', 'show', GrantSet.reserved)
    PermittedAction.create_for_grant_sets('Banner', 'destroy', GrantSet.reserved(only: %w[administrator staff]))
    PermittedAction.create_for_grant_sets('Banner', 'create', GrantSet.reserved(only: %w[administrator staff]))
    PermittedAction.create_for_grant_sets('Banner', 'trash', GrantSet.reserved(only: %w[administrator staff]))
    PermittedAction.create_for_grant_sets('Banner', 'update', GrantSet.reserved(only: %w[administrator staff]))
  end
end
