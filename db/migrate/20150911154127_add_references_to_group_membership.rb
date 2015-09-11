class AddReferencesToGroupMembership < ActiveRecord::Migration
  def up
    add_foreign_key :group_memberships, :groups, on_delete: :cascade
  end

  def down
    remove_foreign_key :group_memberships, :groups
  end
end
