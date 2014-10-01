class AddRoleToMembership < ActiveRecord::Migration
  def change
    add_column :memberships, :role, :integer, default: 0, null: false
  end
end
