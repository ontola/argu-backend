class AddActiveBranch < ActiveRecord::Migration[7.0]
  def up
    add_column :edges, :active_branch, :boolean, default: false, null: false

    Edge.reset_active_branches
  end

  def down
    remove_column :edges, :active_branch, :boolean
  end
end
