class AddOsmColumnsToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :osm_category, :string
    add_column :places, :address, :json
    add_column :places, :extratags, :json
    add_column :places, :namedetails, :json
  end
end
