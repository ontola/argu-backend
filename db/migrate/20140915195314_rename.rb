class Rename < ActiveRecord::Migration
  def change
    rename_column :organisations, :organisation_scope, :org_scope
  end
end
