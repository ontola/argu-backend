class AddLockVersionToForums < ActiveRecord::Migration
  def up
    add_column :forums, :lock_version, :integer, default: 0
  end

  def down
    remove_column :forums, :lock_version
  end
end
