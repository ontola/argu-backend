class DeleteForumPage < ActiveRecord::Migration
  def change
    drop_table :forum_pages
  end
end
