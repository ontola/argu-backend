class RenameForumTagsToTagList < ActiveRecord::Migration
  def change
    rename_column :forums, :tags, :tag_list
  end
end
