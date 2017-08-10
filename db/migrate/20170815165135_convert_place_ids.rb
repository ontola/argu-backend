class ConvertPlaceIds < ActiveRecord::Migration[5.1]
  def up
    add_column :places, :nominatim_id, :integer
    Place.update_all('nominatim_id = id')
    ActiveRecord::Base.connection.execute("SELECT setval('places_id_seq', #{Place.maximum(:id)}, true)")
  end
end
