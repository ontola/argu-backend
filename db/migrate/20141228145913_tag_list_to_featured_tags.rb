class TagListToFeaturedTags < ActiveRecord::Migration
  def change
    rename_column :forums, :tag_list, :featured_tags
  end
end
