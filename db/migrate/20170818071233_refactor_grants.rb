class RefactorGrants < ActiveRecord::Migration[5.1]
  def up
    enable_extension('intarray')
    add_column :grants, :model_type, :string
    add_column :grants, :parent_type, :string
    add_column :grants, :action, :string
    add_column :grants, :permit, :bool
    change_column :grants, :role, :integer, default: nil, null: true
    remove_index :grants, [:group_id, :edge_id]
    Grant.where('role IS NOT NULL').find_each do |grant|
      GrantSet.new(edge_id: grant.edge_id, group_id: grant.group_id, role: grant.role).create_grants
    end
  end

  def down
    disable_extension('intarray')
    remove_column :grants, :model_type, :string
    remove_column :grants, :parent_type, :string
    remove_column :grants, :action, :string
    remove_column :grants, :permit, :bool
    Grant.where(role: nil).destroy_all
    add_index :grants, [:group_id, :edge_id], unique: true
  end
end
