class AddAttributionToCoverPhotos < ActiveRecord::Migration
  def change
    # I left out profiles since that looks like a case where the bio is a more fit location
    add_column :forums, :cover_photo_attribution, :string, default: ''
    add_column :motions, :cover_photo_attribution, :string, default: ''
    add_column :questions, :cover_photo_attribution, :string, default: ''
  end
end
