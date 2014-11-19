class AddCoverToOrganisations < ActiveRecord::Migration
  def up
    add_attachment :forums, :cover_photo
  end

  def down
    remove_attachment :forums, :cover_photo
  end
end
