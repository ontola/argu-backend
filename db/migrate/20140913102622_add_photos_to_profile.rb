class AddPhotosToProfile < ActiveRecord::Migration
  def change
    add_attachment :profiles, :profile_photo
    add_attachment :profiles, :cover_photo

  end
end
