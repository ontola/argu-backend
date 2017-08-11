class AddZoomToPlaces < ActiveRecord::Migration[5.1]
  def change
    add_column :places, :zoom_level, :integer, default: Place::DEFAULT_ZOOM_LEVEL, null: false
    Place.update_all("zoom_level = round(3 + 10 * CAST(COALESCE(osm_importance, '0.1') AS float))")
  end
end
