class ChangeBannersAttributeNames < ActiveRecord::Migration
  def up
    rename_column :banners, :publish_at, :published_at
    add_column :banners, :trashed_at, :datetime, default: nil

    remove_index :announcements,
                 [:publish_at, :sample_size, :audience]
    rename_column :announcements, :publish_at, :published_at
    add_column :announcements, :trashed_at, :datetime, default: nil
  end

  def down
    rename_column :banners, :published_at, :publish_at
    remove_column :banners, :trashed_at

    rename_column :announcements, :published_at, :publish_at
    remove_column :announcements, :trashed_at
  end
end
