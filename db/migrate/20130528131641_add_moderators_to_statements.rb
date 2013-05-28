class AddModeratorsToStatements < ActiveRecord::Migration
  def up
  	add_column :statements, :moderators, :string
  end

  def down
  	remove_column :statements, :moderators
  end
end
