class AddCoverToOrganisations < ActiveRecord::Migration
  def up
    add_attachment :organisations, :cover_photo
  end

  def down
    remove_attachment :organisations, :cover_photo
  end
end
