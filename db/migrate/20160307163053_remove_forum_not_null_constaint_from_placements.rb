class RemoveForumNotNullConstaintFromPlacements < ActiveRecord::Migration
  def change
    change_column :placements, :forum_id, :integer, :null => true
  end
end
