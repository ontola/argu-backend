class RenamePhotosToFiles < ActiveRecord::Migration[5.0]
  def change
    rename_table :photos, :media_objects
    rename_column :media_objects, :image_uid, :content_uid
    add_column :media_objects, :content_type, :string
    add_column :media_objects, :filename, :string
  end
end
