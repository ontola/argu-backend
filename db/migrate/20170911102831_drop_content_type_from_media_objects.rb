class DropContentTypeFromMediaObjects < ActiveRecord::Migration[5.1]
  def change
    remove_column :media_objects, :content_type
  end
end
