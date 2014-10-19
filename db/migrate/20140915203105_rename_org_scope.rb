class RenameOrgScope < ActiveRecord::Migration
  def change
    rename_column :organisations, :org_scope, :scope
  end
end
