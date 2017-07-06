class DropTagsAndTaggings < ActiveRecord::Migration[5.0]
  def up
    drop_table :taggings
    drop_table :tags
    remove_column :forums, :featured_tags
    remove_column :motions, :tag_id
  end
end
