class AddPlacementTypeToPlacements < ActiveRecord::Migration[5.1]
  def change
    add_column :placements, :placement_type, :integer
    Placement.update_all(placement_type: Placement.placement_types[:home])
    change_column_null :placements, :placement_type, false
    remove_index :placements, name: :index_placements_on_placeable_id
    add_index :placements,
              :placeable_id,
              where: "placement_type = 0 AND placeable_type = 'User'",
              unique: true
  end
end
