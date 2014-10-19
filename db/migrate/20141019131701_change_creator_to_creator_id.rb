class ChangeCreatorToCreatorId < ActiveRecord::Migration
  def change
    rename_column :statements, :creator, :creator_id
    rename_column :arguments, :creator, :creator_id
    rename_column :opinions, :creator, :creator_id
  end
end
