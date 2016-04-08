class AddCoverPhotoToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :cover_photo, :string, default: ''
    add_column :projects, :cover_photo_attribution, :string, default: ''
  end
end
