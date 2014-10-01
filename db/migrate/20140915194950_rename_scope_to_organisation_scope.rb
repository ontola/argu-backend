class RenameScopeToOrganisationScope < ActiveRecord::Migration
  def change
    rename_column :organisations, :scope, :organisation_scope
  end
end
