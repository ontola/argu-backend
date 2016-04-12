class ConvertPublishedAtToIsPublished < ActiveRecord::Migration
  def change
    remove_column :blog_posts, :published_at, :timestamp
    remove_column :projects, :published_at, :timestamp

    add_column :blog_posts, :is_published, :boolean, default: false, null: false
    add_column :projects, :is_published, :boolean, default: false, null: false
    add_index :blog_posts, ['forum_id', 'is_published']
    add_index :projects, ['forum_id', 'is_published']
  end
end
