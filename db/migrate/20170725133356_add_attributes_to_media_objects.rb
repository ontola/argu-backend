class AddAttributesToMediaObjects < ActiveRecord::Migration[5.0]
  def change
    add_column :media_objects, :content_attributes, :hstore
    add_index :media_objects, :content_attributes, using: :gin
  end
end
