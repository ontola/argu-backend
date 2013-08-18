class AddModeratorsToStatement < ActiveRecord::Migration
  def up
  	add_column :statements, :moderators, :integer, array: true, default: []
  end

  def down
  	remove_column :statements, :moderators
  end
end
