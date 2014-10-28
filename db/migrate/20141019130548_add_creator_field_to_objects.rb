class AddCreatorFieldToObjects < ActiveRecord::Migration
  def change
    add_column :statements, :creator, :integer
    add_column :arguments, :creator, :integer
    add_column :opinions, :creator, :integer
  end
end
