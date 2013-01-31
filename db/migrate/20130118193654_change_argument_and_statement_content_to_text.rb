class ChangeArgumentAndStatementContentToText < ActiveRecord::Migration
  def up
  	change_column :arguments, :content, :text
  	change_column :statements, :content, :text
  end

  def down
  	change_column :arguments, :content, :string
  	change_column :statements, :content, :string
  end
end
