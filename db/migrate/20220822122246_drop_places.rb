class DropPlaces < ActiveRecord::Migration[7.0]
  def change
    Placement.where(placeable_type: 'User').delete_all
    Placement.where(placement_type: 1).delete_all
    raise('Places without coordinates found') if Placement.joins('INNER JOIN places ON placements.place_id = places.id').where(places: {lat: nil, lon: nil}).any?

    rename_column :placements, :placeable_id, :edge_id

    add_column :placements, :lat, :decimal, precision: 64, scale: 12
    add_column :placements, :lon, :decimal, precision: 64, scale: 12
    add_column :placements, :zoom_level, :integer, default: 13, null: false
    add_column :placements, :root_id, :uuid

    Placement.connection.update('UPDATE placements SET root_id = edges.root_id FROM edges WHERE edges.uuid = placements.edge_id')
    Placement.connection.update('UPDATE placements SET lat = places.lat, lon = places.lon, zoom_level = places.zoom_level FROM places WHERE places.id = placements.place_id')

    change_column_null :placements, :lat, false
    change_column_null :placements, :lon, false
    change_column_null :placements, :root_id, false

    remove_column :placements, :about
    remove_column :placements, :title
    remove_column :placements, :creator_id
    remove_column :placements, :publisher_id
    remove_column :placements, :forum_id
    remove_column :placements, :placeable_type
    remove_column :placements, :placement_type
    remove_column :placements, :place_id

    drop_table :places
  end
end
