class AddPartialIndexForHomePlacements < ActiveRecord::Migration
  def up
    add_index :placements,
              :placeable_id,
              where: "title = 'home' AND placeable_type = 'User'",
              unique: true
  end

  def down
    remove_index :placements, :placeable_id
  end
end
