class RemoveModeratorsFromStatements < ActiveRecord::Migration
  def up
  	remove_column :statements, :moderators
  end

  def down
  	add_column :statements, :moderators, :string
  end
end
